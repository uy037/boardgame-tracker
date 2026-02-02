from flask import Flask, render_template, request, redirect, url_for, flash, jsonify, session
from flask_login import LoginManager, login_user, logout_user, login_required, current_user
from models import db, bcrypt, User, Game, Rating, LoginLog, Poll, PollOption, PollVote
from bgg_api import BGGClient
from config import Config
from datetime import datetime
import pytz
import json
from datetime import datetime, timedelta
import sys
import locale

# Configurar encoding UTF-8
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')
if hasattr(sys.stderr, 'reconfigure'):
    sys.stderr.reconfigure(encoding='utf-8')

# Configurar locale para español (Uruguay/Argentina)
try:
    locale.setlocale(locale.LC_ALL, 'es_UY.UTF-8')
except:
    try:
        locale.setlocale(locale.LC_ALL, 'es_ES.UTF-8')
    except:
        try:
            locale.setlocale(locale.LC_ALL, 'C.UTF-8')
        except:
            pass  # Si ninguno funciona, continuar

# Función para convertir UTC a GMT-3
def to_local_time(utc_dt):
    if utc_dt is None:
        return None
    return utc_dt - timedelta(hours=3)

# Registrar filtro para las plantillas

app = Flask(__name__)
app.config.from_object(Config)
app.config['JSON_AS_ASCII'] = False

# Filtro para convertir UTC a GMT-3 (Uruguay)
@app.template_filter('gmt3')
def gmt3_filter(utc_dt):
    if utc_dt is None:
        return 'Nunca'
    from datetime import timedelta
    local_dt = utc_dt - timedelta(hours=3)
    return local_dt.strftime('%d/%m/%Y %H:%M')

# Registrar filtro de timezone
@app.template_filter('local_time')
def local_time_filter(utc_dt):
    if utc_dt is None:
        return 'Nunca'
    local_dt = utc_dt - timedelta(hours=3)
    return local_dt.strftime('%d/%m/%Y %H:%M')

db.init_app(app)
bcrypt.init_app(app)

login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'
login_manager.login_message = 'Por favor inicia sesión para acceder a esta página.'

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# Crear tablas y usuario admin inicial
with app.app_context():
    db.create_all()

    # Crear usuario admin si no existe
    admin = User.query.filter_by(username='admin').first()
    if not admin:
        admin = User(username='admin', role='admin')
        admin.set_password('admin123')  # CAMBIAR ESTO
        db.session.add(admin)

    # Crear usuario invitado si no existe
    guest = User.query.filter_by(username='invitado').first()
    if not guest:
        guest = User(username='invitado', role='guest')
        guest.set_password('invitado')
        db.session.add(guest)

    db.session.commit()
 
# Rutas de autenticación
@app.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('index'))

    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')

        user = User.query.filter(User.username.ilike(username)).first()

        if user and user.check_password(password):
            login_user(user)

            # Configurar zona horaria
            tz = pytz.timezone('America/Montevideo')
            now_local = datetime.now(tz)

            # Registrar el login con hora local
            user.last_login = datetime.now(tz)

            # Crear log de login
            login_log = LoginLog(
                user_id=user.id,
                login_time=now_local,
                ip_address=request.remote_addr,
                user_agent=request.headers.get('User-Agent', '')[:500]
            )
            db.session.add(login_log)
            db.session.commit()

            # Verificar encuestas pendientes (solo para usuarios normales y admin)
            if user.role != 'guest':
                pending_polls = Poll.get_pending_polls_for_user(user.id)
                if pending_polls:
                    # Si hay encuestas pendientes, redirigir a la primera
                    flash(f'Tienes {len(pending_polls)} encuesta(s) pendiente(s) de votar', 'info')
                    return redirect(url_for('poll_vote', poll_id=pending_polls[0].id))

            next_page = request.args.get('next')
            return redirect(next_page or url_for('index'))
        else:
            flash('Usuario o contraseña incorrectos', 'error')

    return render_template('login.html')
 
@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('login'))
 
# Rutas principales
@app.route('/')
@login_required
def index():
    page = request.args.get('page', 1, type=int)
    search = request.args.get('search', '')

    # Obtener ordenamiento: primero de la URL, luego de sesión, o 'newest' por defecto
    sort_by = request.args.get('sort')
    if sort_by:
        # Si viene en la URL, guardarlo en sesión
        session['sort_preference'] = sort_by
    else:
        # Si no viene en URL, usar el de la sesión o 'newest'
        sort_by = session.get('sort_preference', 'newest')

    query = Game.query
    if search:
        query = query.filter(Game.name.ilike(f'%{search}%'))

    # Aplicar ordenamiento según la opción seleccionada
    if sort_by == 'rating_desc':
        # Ordenar por clasificación promedio (mayor a menor), luego por cantidad de votos
        query = query.outerjoin(Rating).group_by(Game.id).order_by(
            db.func.coalesce(db.func.avg(Rating.score), 0).desc(),
            db.func.count(Rating.id).desc()
        )
    elif sort_by == 'rating_asc':
        # Ordenar por clasificación promedio (menor a mayor), luego por cantidad de votos
        query = query.outerjoin(Rating).group_by(Game.id).order_by(
            db.func.coalesce(db.func.avg(Rating.score), 0).asc(),
            db.func.count(Rating.id).asc()
        )
    elif sort_by == 'my_rating':
        query = query.join(Rating).filter(Rating.user_id == current_user.id).order_by(Rating.score.desc())
    elif sort_by == 'complexity_desc':
        query = query.order_by(db.func.coalesce(Game.complexity, 0).desc())
    elif sort_by == 'complexity_asc':
        query = query.order_by(db.func.coalesce(Game.complexity, 0).asc())
    else:  # 'newest' por defecto
        query = query.order_by(Game.added_at.desc())

    games = query.paginate(
        page=page, per_page=app.config['ITEMS_PER_PAGE'], error_out=False
    )

    # Obtener próxima juntada confirmada
    next_event = Poll.get_next_confirmed_event()
    
    return render_template('index.html', games=games, search=search, sort_by=sort_by, next_event=next_event)
	
@app.route('/game/<int:game_id>')
@login_required
def game_detail(game_id):
    game = Game.query.get_or_404(game_id)

    # Parsear JSON fields
    categories = json.loads(game.categories) if game.categories else []
    mechanics = json.loads(game.mechanics) if game.mechanics else []
    designers = json.loads(game.designers) if game.designers else []
    publishers = json.loads(game.publishers) if game.publishers else []

    user_rating = game.user_rating(current_user.id)

    return render_template('game_detail.html', 
                         game=game, 
                         categories=categories,
                         mechanics=mechanics,
                         designers=designers,
                         publishers=publishers,
                         user_rating=user_rating)
	
@app.route('/game/add', methods=['GET', 'POST'])
@login_required
def add_game():
    if not current_user.is_admin():
        flash('No tienes permisos para agregar juegos', 'error')
        return redirect(url_for('index'))

    if request.method == 'POST':
        # Verificar si es búsqueda en BGG o formulario manual
        if 'search' in request.form:
            search_query = request.form.get('search')
            bgg_results = BGGClient.search_game(search_query)
            return render_template('add_game.html', results=bgg_results, search=search_query)
        else:
            # Agregar juego manualmente
            try:
                # Procesar categorías, mecánicas, diseñadores y publishers como JSON
                categories = request.form.get('categories', '').strip()
                if categories and not categories.startswith('['):
                    # Si el usuario ingresó texto separado por comas, convertir a JSON
                    categories = json.dumps([c.strip() for c in categories.split(',') if c.strip()])
                elif not categories:
                    categories = '[]'

                mechanics = request.form.get('mechanics', '').strip()
                if mechanics and not mechanics.startswith('['):
                    mechanics = json.dumps([m.strip() for m in mechanics.split(',') if m.strip()])
                elif not mechanics:
                    mechanics = '[]'

                designers = request.form.get('designers', '').strip()
                if designers and not designers.startswith('['):
                    designers = json.dumps([d.strip() for d in designers.split(',') if d.strip()])
                elif not designers:
                    designers = '[]'

                publishers = request.form.get('publishers', '').strip()
                if publishers and not publishers.startswith('['):
                    publishers = json.dumps([p.strip() for p in publishers.split(',') if p.strip()])
                elif not publishers:
                    publishers = '[]'

                game = Game(
                    name=request.form.get('name'),
                    description=request.form.get('description', ''),
                    year_published=int(request.form.get('year_published')) if request.form.get('year_published') else None,
                    image_url=request.form.get('image_url', ''),
                    thumbnail_url=request.form.get('thumbnail_url', ''),
                    min_players=int(request.form.get('min_players')) if request.form.get('min_players') else None,
                    max_players=int(request.form.get('max_players')) if request.form.get('max_players') else None,
                    playing_time=int(request.form.get('playing_time')) if request.form.get('playing_time') else None,
                    min_age=int(request.form.get('min_age')) if request.form.get('min_age') else None,
                    complexity=float(request.form.get('complexity')) if request.form.get('complexity') else None,
                    categories=categories,
                    mechanics=mechanics,
                    designers=designers,
                    publishers=publishers,
                    bgg_link=request.form.get('bgg_link', '')
                )
                db.session.add(game)
                db.session.commit()
                flash(f'Juego "{game.name}" agregado exitosamente', 'success')
                return redirect(url_for('game_detail', game_id=game.id))
            except Exception as e:
                db.session.rollback()
                flash(f'Error al agregar juego: {str(e)}', 'error')
                return redirect(url_for('add_game'))

    return render_template('add_game.html')

@app.route('/game/import/<int:bgg_id>', methods=['POST'])
@login_required
def import_game(bgg_id):
    if not current_user.is_admin():
        return jsonify({'error': 'No autorizado'}), 403

    # Verificar si ya existe
    existing = Game.query.filter_by(bgg_id=bgg_id).first()
    if existing:
        flash('Este juego ya está en el catálogo', 'warning')
        return redirect(url_for('game_detail', game_id=existing.id))

    # Obtener datos de BGG
    game_data = BGGClient.get_game_details(bgg_id)

    if not game_data:
        flash('Error al obtener datos del juego desde BGG. La API requiere autenticación.', 'error')
        return redirect(url_for('add_game'))

    # Crear juego
    game = Game(**game_data)
    db.session.add(game)
    db.session.commit()

    flash(f'Juego "{game.name}" agregado exitosamente', 'success')
    return redirect(url_for('game_detail', game_id=game.id))

@app.route('/game/<int:game_id>/rate', methods=['POST'])
@login_required
def rate_game(game_id):
    if current_user.role == 'guest':
        return jsonify({'error': 'Los invitados no pueden calificar'}), 403
    
    game = Game.query.get_or_404(game_id)
    score = request.form.get('score', type=int)
    comment = request.form.get('comment', '')
    
    if not score or score < 1 or score > 10:
        flash('La calificación debe estar entre 1 y 10', 'error')
        return redirect(url_for('game_detail', game_id=game_id))
    
    # Buscar rating existente
    rating = Rating.query.filter_by(user_id=current_user.id, game_id=game_id).first()
    
    if rating:
        rating.score = score
        rating.comment = comment
    else:
        rating = Rating(user_id=current_user.id, game_id=game_id, score=score, comment=comment)
        db.session.add(rating)
    
    db.session.commit()
    flash('Calificación guardada', 'success')
    return redirect(url_for('game_detail', game_id=game_id))

@app.route('/users')
@login_required
def users():
    if not current_user.is_admin():
        flash('No tienes permisos para ver usuarios', 'error')
        return redirect(url_for('index'))
    
    all_users = User.query.all()
    return render_template('users.html', users=all_users)

@app.route('/user/add', methods=['POST'])
@login_required
def add_user():
    if not current_user.is_admin():
        return jsonify({'error': 'No autorizado'}), 403
    
    username = request.form.get('username')
    password = request.form.get('password')
    role = request.form.get('role', 'user')
    
    if not username or not password:
        flash('Usuario y contraseña son requeridos', 'error')
        return redirect(url_for('users'))
    
#   existing = User.query.filter_by(username=username).first()
    existing = User.query.filter(User.username.ilike(username)).first()
    if existing:
        flash('El usuario ya existe', 'error')
        return redirect(url_for('users'))
    
    user = User(username=username, role=role)
    user.set_password(password)
    db.session.add(user)
    db.session.commit()
    
    flash(f'Usuario {username} creado', 'success')
    return redirect(url_for('users'))

@app.route('/game/<int:game_id>/edit', methods=['GET', 'POST'])
@login_required
def edit_game(game_id):
    if not current_user.is_admin():
        flash('No tienes permisos para editar juegos', 'error')
        return redirect(url_for('game_detail', game_id=game_id))
    
    game = Game.query.get_or_404(game_id)
    
    if request.method == 'POST':
        try:
            # Actualizar campos básicos
            game.name = request.form.get('name')
            game.description = request.form.get('description', '')
            game.year_published = int(request.form.get('year_published')) if request.form.get('year_published') else None
            game.image_url = request.form.get('image_url', '')
            game.thumbnail_url = request.form.get('thumbnail_url', '')
            game.min_players = int(request.form.get('min_players')) if request.form.get('min_players') else None
            game.max_players = int(request.form.get('max_players')) if request.form.get('max_players') else None
            game.playing_time = int(request.form.get('playing_time')) if request.form.get('playing_time') else None
            game.min_age = int(request.form.get('min_age')) if request.form.get('min_age') else None
            game.complexity = float(request.form.get('complexity')) if request.form.get('complexity') else None
            game.bgg_link = request.form.get('bgg_link', '')
            
            # Procesar campos de lista como JSON
            categories = request.form.get('categories', '').strip()
            if categories and not categories.startswith('['):
                categories = json.dumps([c.strip() for c in categories.split(',') if c.strip()])
            elif not categories:
                categories = '[]'
            game.categories = categories
            
            mechanics = request.form.get('mechanics', '').strip()
            if mechanics and not mechanics.startswith('['):
                mechanics = json.dumps([m.strip() for m in mechanics.split(',') if m.strip()])
            elif not mechanics:
                mechanics = '[]'
            game.mechanics = mechanics
            
            designers = request.form.get('designers', '').strip()
            if designers and not designers.startswith('['):
                designers = json.dumps([d.strip() for d in designers.split(',') if d.strip()])
            elif not designers:
                designers = '[]'
            game.designers = designers
            
            publishers = request.form.get('publishers', '').strip()
            if publishers and not publishers.startswith('['):
                publishers = json.dumps([p.strip() for p in publishers.split(',') if p.strip()])
            elif not publishers:
                publishers = '[]'
            game.publishers = publishers
            
            db.session.commit()
            flash(f'Juego "{game.name}" actualizado exitosamente', 'success')
            return redirect(url_for('game_detail', game_id=game.id))
        except Exception as e:
            db.session.rollback()
            flash(f'Error al actualizar juego: {str(e)}', 'error')
    
    # Para GET, preparar datos para el formulario
    categories_str = ', '.join(json.loads(game.categories)) if game.categories else ''
    mechanics_str = ', '.join(json.loads(game.mechanics)) if game.mechanics else ''
    designers_str = ', '.join(json.loads(game.designers)) if game.designers else ''
    publishers_str = ', '.join(json.loads(game.publishers)) if game.publishers else ''
    
    return render_template('edit_game.html', 
                         game=game,
                         categories_str=categories_str,
                         mechanics_str=mechanics_str,
                         designers_str=designers_str,
                         publishers_str=publishers_str)

@app.route('/game/<int:game_id>/delete', methods=['POST'])
@login_required
def delete_game(game_id):
    if not current_user.is_admin():
        return jsonify({'error': 'No autorizado'}), 403
    
    game = Game.query.get_or_404(game_id)
    game_name = game.name
    
    try:
        db.session.delete(game)
        db.session.commit()
        flash(f'Juego "{game_name}" eliminado exitosamente', 'success')
        return redirect(url_for('index'))
    except Exception as e:
        db.session.rollback()
        flash(f'Error al eliminar juego: {str(e)}', 'error')
        return redirect(url_for('game_detail', game_id=game_id))

@app.route('/change-password', methods=['GET', 'POST'])
@login_required
def change_password():
    if current_user.role == 'guest':
        flash('Los usuarios invitados no pueden cambiar su contraseña', 'error')
        return redirect(url_for('index'))
    
    if request.method == 'POST':
        current_password = request.form.get('current_password')
        new_password = request.form.get('new_password')
        confirm_password = request.form.get('confirm_password')
        
        if not current_user.check_password(current_password):
            flash('La contraseña actual es incorrecta', 'error')
            return redirect(url_for('change_password'))
        
        if new_password != confirm_password:
            flash('Las contraseñas nuevas no coinciden', 'error')
            return redirect(url_for('change_password'))
        
        if len(new_password) < 4:
            flash('La contraseña debe tener al menos 4 caracteres', 'error')
            return redirect(url_for('change_password'))
        
        current_user.set_password(new_password)
        db.session.commit()
        flash('Contraseña cambiada exitosamente', 'success')
        return redirect(url_for('index'))
    
    return render_template('change_password.html')

@app.route('/user/<int:user_id>/edit', methods=['POST'])
@login_required
def edit_user(user_id):
    if not current_user.is_admin():
        return jsonify({'error': 'No autorizado'}), 403
    
    user = User.query.get_or_404(user_id)
    
    # No permitir que el admin se quite a sí mismo el rol de admin
    if user.id == current_user.id and request.form.get('role') != 'admin':
        flash('No puedes quitarte a ti mismo el rol de administrador', 'error')
        return redirect(url_for('users'))
    
    new_password = request.form.get('password')
    if new_password:
        if len(new_password) < 4:
            flash('La contraseña debe tener al menos 4 caracteres', 'error')
            return redirect(url_for('users'))
        user.set_password(new_password)
    
    user.role = request.form.get('role', user.role)
    
    db.session.commit()
    flash(f'Usuario {user.username} actualizado exitosamente', 'success')
    return redirect(url_for('users'))

@app.route('/user/<int:user_id>/delete', methods=['POST'])
@login_required
def delete_user(user_id):
    if not current_user.is_admin():
        return jsonify({'error': 'No autorizado'}), 403
    
    user = User.query.get_or_404(user_id)
    
    # No permitir que el admin se elimine a sí mismo
    if user.id == current_user.id:
        flash('No puedes eliminarte a ti mismo', 'error')
        return redirect(url_for('users'))
    
    username = user.username
    db.session.delete(user)
    db.session.commit()
    flash(f'Usuario {username} eliminado exitosamente', 'success')
    return redirect(url_for('users'))

@app.route('/user/<int:user_id>/login-history')
@login_required
def user_login_history(user_id):
    # Solo el propio usuario o admin puede ver el historial
    if current_user.id != user_id and not current_user.is_admin():
        flash('No tienes permisos para ver este historial', 'error')
        return redirect(url_for('index'))
    
    user = User.query.get_or_404(user_id)
    page = request.args.get('page', 1, type=int)
    
    logs = LoginLog.query.filter_by(user_id=user_id).order_by(
        LoginLog.login_time.desc()
    ).paginate(page=page, per_page=20, error_out=False)
    
    return render_template('login_history.html', user=user, logs=logs)

@app.route('/admin/login-history')
@login_required
def admin_login_history():
    if not current_user.is_admin():
        flash('No tienes permisos para ver esta página', 'error')
        return redirect(url_for('index'))
    
    page = request.args.get('page', 1, type=int)
    user_filter = request.args.get('user', type=int)
    
    query = LoginLog.query
    if user_filter:
        query = query.filter_by(user_id=user_filter)
    
    logs = query.order_by(LoginLog.login_time.desc()).paginate(
        page=page, per_page=50, error_out=False
    )
    
    all_users = User.query.order_by(User.username).all()
    
    return render_template('admin_login_history.html', logs=logs, all_users=all_users, user_filter=user_filter)


# ============================================
# RUTAS DE ENCUESTAS
# ============================================

@app.route('/polls')
@login_required
def polls():
    """Listar todas las encuestas - NO disponible para invitados"""
    if current_user.role == 'guest':
        flash('Los usuarios invitados no tienen acceso a las encuestas', 'warning')
        return redirect(url_for('index'))
    
    polls = Poll.query.order_by(Poll.created_at.desc()).all()
    return render_template('polls.html', polls=polls)


@app.route('/poll/create', methods=['GET', 'POST'])
@login_required
def poll_create():
    """Crear nueva encuesta - SOLO ADMIN"""
    if not current_user.is_admin():
        flash('Solo los administradores pueden crear encuestas', 'error')
        return redirect(url_for('polls'))
    
    if request.method == 'POST':
        title = request.form.get('title')
        description = request.form.get('description')
        
        if not title:
            flash('El título es obligatorio', 'error')
            return redirect(url_for('poll_create'))
        
        # Crear la encuesta
        poll = Poll(
            title=title,
            description=description,
            creator_id=current_user.id
        )
        db.session.add(poll)
        db.session.flush()  # Para obtener el poll.id
        
        # Agregar opciones de fechas
        dates = request.form.getlist('dates[]')
        descriptions = request.form.getlist('descriptions[]')
        
        for date_str, desc in zip(dates, descriptions):
            if date_str:
                try:
                    # Convertir string a datetime
                    date_obj = datetime.strptime(date_str, '%Y-%m-%dT%H:%M')
                    option = PollOption(
                        poll_id=poll.id,
                        date_time=date_obj,
                        description=desc
                    )
                    db.session.add(option)
                except ValueError:
                    flash(f'Fecha inválida: {date_str}', 'error')
                    db.session.rollback()
                    return redirect(url_for('poll_create'))
        
        db.session.commit()
        flash('Encuesta creada exitosamente', 'success')
        return redirect(url_for('poll_vote', poll_id=poll.id))
    
    return render_template('poll_create.html')


@app.route('/poll/<int:poll_id>/vote', methods=['GET', 'POST'])
@login_required
def poll_vote(poll_id):
    """Votar en una encuesta - NO disponible para invitados"""
    if current_user.role == 'guest':
        flash('Los usuarios invitados no pueden votar en encuestas', 'warning')
        return redirect(url_for('index'))
    
    poll = Poll.query.get_or_404(poll_id)
    
    if not poll.is_open:
        flash('Esta encuesta está cerrada', 'warning')
        return redirect(url_for('poll_results', poll_id=poll_id))
    
    if request.method == 'POST':
        # Procesar votos y comentarios
        for option in poll.options:
            vote_value = request.form.get(f'vote_{option.id}')
            comment_text = request.form.get(f'comment_{option.id}', '').strip()
            
            if vote_value is not None:
                vote_value = int(vote_value)
                
                # Buscar si ya existe un voto de este usuario para esta opción
                existing_vote = PollVote.query.filter_by(
                    option_id=option.id,
                    user_id=current_user.id
                ).first()
                
                if existing_vote:
                    # Actualizar voto existente
                    existing_vote.value = vote_value
                    existing_vote.comment = comment_text if comment_text else None
                    existing_vote.voted_at = datetime.utcnow()
                else:
                    # Crear nuevo voto
                    vote = PollVote(
                        option_id=option.id,
                        user_id=current_user.id,
                        value=vote_value,
                        comment=comment_text if comment_text else None
                    )
                    db.session.add(vote)
        
        db.session.commit()
        flash('Tus votos han sido guardados', 'success')
        return redirect(url_for('poll_results', poll_id=poll_id))
    
    return render_template('poll_vote.html', poll=poll)


@app.route('/poll/<int:poll_id>/results')
@login_required
def poll_results(poll_id):
    """Ver resultados de una encuesta - NO disponible para invitados"""
    if current_user.role == 'guest':
        flash('Los usuarios invitados no tienen acceso a las encuestas', 'warning')
        return redirect(url_for('index'))
    
    poll = Poll.query.get_or_404(poll_id)
    results = poll.get_results()
    
    # Obtener todos los usuarios que votaron
    all_voters = set()
    for option in poll.options:
        voters = PollVote.query.filter_by(option_id=option.id).all()
        for vote in voters:
            all_voters.add(vote.user_id)
    
    voters_count = len(all_voters)
    
    return render_template('poll_results.html', poll=poll, results=results, voters_count=voters_count)


@app.route('/poll/<int:poll_id>/toggle', methods=['POST'])
@login_required
def poll_toggle(poll_id):
    """Abrir/cerrar una encuesta - SOLO ADMIN"""
    poll = Poll.query.get_or_404(poll_id)
    
    if not current_user.is_admin():
        flash('No tienes permiso para modificar esta encuesta', 'error')
        return redirect(url_for('polls'))
    
    poll.is_open = not poll.is_open
    if not poll.is_open:
        poll.closed_at = datetime.utcnow()
    else:
        poll.closed_at = None
    
    db.session.commit()
    
    status = 'abierta' if poll.is_open else 'cerrada'
    flash(f'Encuesta {status}', 'success')
    return redirect(url_for('poll_results', poll_id=poll_id))


@app.route('/poll/<int:poll_id>/delete', methods=['POST'])
@login_required
def poll_delete(poll_id):
    """Eliminar una encuesta - SOLO ADMIN"""
    poll = Poll.query.get_or_404(poll_id)
    
    if not current_user.is_admin():
        flash('No tienes permiso para eliminar esta encuesta', 'error')
        return redirect(url_for('polls'))
    
    db.session.delete(poll)
    db.session.commit()
    flash('Encuesta eliminada', 'success')
    return redirect(url_for('polls'))
