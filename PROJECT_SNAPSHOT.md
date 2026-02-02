# Board Game Tracker - Snapshot del Proyecto
Fecha: 29 Enero 2026

## Estructura de Archivos
total 136
drwxrwxr-x 11 pi pi  4096 Jan 29 22:49 .
drwx------ 13 pi pi  4096 Jan 29 22:14 ..
-rw-rw-r--  1 pi pi 21916 Jan 29 00:26 app.py
drwxrwxr-x  2 pi pi  4096 Jan 29 22:26 backups
-rwxrwxr-x  1 pi pi  1060 Jan 27 02:38 backup.sh
-rw-rw-r--  1 pi pi  3048 Jan 25 01:43 bgg_api.py
-rw-rw-r--  1 pi pi  3048 Jan 25 19:47 bgg_api.py.gpt
drwxrwxr-x  4 pi pi  4096 Jan 26 17:21 certbot
-rwxrwxr-x  1 pi pi   693 Jan 26 23:08 check_logs.sh
-rwxrwxr-x  1 pi pi   393 Jan 26 23:13 check_status.sh
-rw-rw-r--  1 pi pi   419 Jan 24 22:45 config.py
-rw-rw-r--  1 pi pi  1826 Jan 27 22:40 docker-compose.yml
-rw-rw-r--  1 pi pi   808 Jan 24 22:38 Dockerfile
-rw-rw-r--  1 pi pi   219 Jan 28 02:23 .dockerignore
-rw-rw-r--  1 pi pi   175 Jan 24 22:47 .env
drwxrwxr-x  8 pi pi  4096 Jan 29 22:13 .git
-rw-rw-r--  1 pi pi   184 Jan 27 15:15 .gitignore
drwxrwxr-x  2 pi pi  4096 Jan 24 22:20 instance
drwxrwxr-x  2 pi pi  4096 Jan 27 22:40 logs
-rw-rw-r--  1 pi pi  8034 Jan 29 22:18 models.py
drwxrwxr-x  3 pi pi  4096 Jan 26 23:05 nginx
-rw-rw-r--  1 pi pi    93 Jan 29 22:49 PROJECT_SNAPSHOT.md
drwxr-xr-x  2 pi pi  4096 Jan 29 22:18 __pycache__
-rw-rw-r--  1 pi pi   159 Jan 28 02:21 requirements.txt
-rwxrwxr-x  1 pi pi   735 Jan 26 23:28 restore.sh
drwxrwxr-x  5 pi pi  4096 Jan 24 22:20 static
drwxrwxr-x  2 pi pi  4096 Jan 28 22:43 templates
-rw-rw-r--  1 pi pi   124 Jan 25 01:37 test.py

## Templates disponibles

total 80
drwxrwxr-x  2 pi pi 4096 Jan 28 22:43 .
drwxrwxr-x 11 pi pi 4096 Jan 29 22:49 ..
-rw-rw-r--  1 pi pi 8234 Jan 25 21:50 add_game.html
-rw-rw-r--  1 pi pi 4335 Jan 28 22:43 admin_login_history.html
-rw-rw-r--  1 pi pi 6414 Jan 26 02:35 base.html
-rw-rw-r--  1 pi pi 1978 Jan 26 02:12 change_password.html
-rw-rw-r--  1 pi pi 7548 Jan 25 22:43 edit_game.html
-rw-rw-r--  1 pi pi 7131 Jan 27 22:25 game_detail.html
-rw-rw-r--  1 pi pi 6816 Jan 27 22:24 index.html
-rw-rw-r--  1 pi pi 3291 Jan 28 22:42 login_history.html
-rw-rw-r--  1 pi pi 1370 Jan 25 23:00 login.html
-rw-rw-r--  1 pi pi 7809 Jan 28 22:36 users.html

---
## app.py
```python
from flask import Flask, render_template, request, redirect, url_for, flash, jsonify, session
from flask_login import LoginManager, login_user, logout_user, login_required, current_user
from models import db, bcrypt, User, Game, Rating, LoginLog
from bgg_api import BGGClient
from config import Config
from datetime import datetime
import pytz
import json
from datetime import datetime, timedelta

# Función para convertir UTC a GMT-3
def to_local_time(utc_dt):
    if utc_dt is None:
        return None
    return utc_dt - timedelta(hours=3)

# Registrar filtro para las plantillas

app = Flask(__name__)
app.config.from_object(Config)

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

    return render_template('index.html', games=games, search=search, sort_by=sort_by)

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

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
```


---
## models.py
```python
from flask_sqlalchemy import SQLAlchemy
from flask_login import UserMixin
from datetime import datetime
import pytz
from flask_bcrypt import Bcrypt

db = SQLAlchemy()
bcrypt = Bcrypt()

class User(UserMixin, db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(200), nullable=False)
    role = db.Column(db.String(20), default='user')  # admin, user, guest
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    last_login = db.Column(db.DateTime)  # NUEVO
    
    ratings = db.relationship('Rating', back_populates='user', cascade='all, delete-orphan')
    login_logs = db.relationship('LoginLog', back_populates='user', cascade='all, delete-orphan')  # NUEVO
    
    def set_password(self, password):
        self.password_hash = bcrypt.generate_password_hash(password).decode('utf-8')
    
    def check_password(self, password):
        return bcrypt.check_password_hash(self.password_hash, password)
    
    def is_admin(self):
        return self.role == 'admin'


class Game(db.Model):
    __tablename__ = 'games'
    
    id = db.Column(db.Integer, primary_key=True)
    bgg_id = db.Column(db.Integer, unique=True, nullable=True)
    name = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    year_published = db.Column(db.Integer)
    image_url = db.Column(db.String(500))
    thumbnail_url = db.Column(db.String(500))
    min_players = db.Column(db.Integer)
    max_players = db.Column(db.Integer)
    playing_time = db.Column(db.Integer)
    min_age = db.Column(db.Integer)
    complexity = db.Column(db.Float)  # 1-5 según BGG
    categories = db.Column(db.Text)  # JSON string
    mechanics = db.Column(db.Text)   # JSON string
    designers = db.Column(db.Text)   # JSON string
    publishers = db.Column(db.Text)  # JSON string
    bgg_link = db.Column(db.String(500))
    added_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    ratings = db.relationship('Rating', back_populates='game', cascade='all, delete-orphan')
    
    def average_rating(self):
        if not self.ratings:
            return 0
        return sum(r.score for r in self.ratings) / len(self.ratings)
    
    def user_rating(self, user_id):
        rating = Rating.query.filter_by(game_id=self.id, user_id=user_id).first()
        return rating.score if rating else None


class Rating(db.Model):
    __tablename__ = 'ratings'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    game_id = db.Column(db.Integer, db.ForeignKey('games.id'), nullable=False)
    score = db.Column(db.Integer, nullable=False)  # 1-10
    comment = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    user = db.relationship('User', back_populates='ratings')
    game = db.relationship('Game', back_populates='ratings')
    
    __table_args__ = (
        db.UniqueConstraint('user_id', 'game_id', name='unique_user_game_rating'),
    )

class LoginLog(db.Model):
    __tablename__ = 'login_logs'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    login_time = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    login_time = db.Column(db.DateTime, default=lambda: datetime.now(pytz.timezone('America/Montevideo')), nullable=False)
    ip_address = db.Column(db.String(45))  # IPv6 puede ser hasta 45 caracteres
    user_agent = db.Column(db.String(500))
    
    user = db.relationship('User', back_populates='login_logs')

class Poll(db.Model):
    __tablename__ = 'polls'
    
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    creator_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    is_open = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    closed_at = db.Column(db.DateTime)
    
    creator = db.relationship('User', backref='polls_created')
    options = db.relationship('PollOption', backref='poll', cascade='all, delete-orphan', lazy='dynamic')
    
    def __repr__(self):
        return f'<Poll {self.title}>'
    
    def get_results(self):
        """Calcular resultados de la encuesta"""
        results = []
        for option in self.options:
            votes = PollVote.query.filter_by(option_id=option.id).all()
            
            # Contar votos por color
            green = sum(1 for v in votes if v.value == 5)
            yellow = sum(1 for v in votes if v.value == 3)
            orange = sum(1 for v in votes if v.value == 2)
            red = sum(1 for v in votes if v.value == 0)
            
            # Calcular pueden asistir (todos menos rojos)
            can_attend = green + yellow + orange
            
            # Calcular promedio de comodidad (solo de los que pueden)
            if can_attend > 0:
                comfort_avg = sum(v.value for v in votes if v.value > 0) / can_attend
            else:
                comfort_avg = 0
            
            # Puntaje final: cantidad * comfort (normalizado)
            # Comfort normalizado: 0-1 donde 5=1, 3=0.6, 2=0.4
            if can_attend > 0:
                comfort_normalized = comfort_avg / 5.0
                final_score = can_attend * (1 + comfort_normalized)  # Pondera cantidad y comfort
            else:
                final_score = 0
            
            results.append({
                'option': option,
                'can_attend': can_attend,
                'green': green,
                'yellow': yellow,
                'orange': orange,
                'red': red,
                'comfort_avg': comfort_avg,
                'final_score': final_score,
                'total_votes': len(votes)
            })
        
        # Ordenar por puntaje final
        results.sort(key=lambda x: x['final_score'], reverse=True)
        return results


class PollOption(db.Model):
    __tablename__ = 'poll_options'
    
    id = db.Column(db.Integer, primary_key=True)
    poll_id = db.Column(db.Integer, db.ForeignKey('polls.id'), nullable=False)
    date_time = db.Column(db.DateTime, nullable=False)
    description = db.Column(db.String(200))
    
    votes = db.relationship('PollVote', backref='option', cascade='all, delete-orphan', lazy='dynamic')
    
    def __repr__(self):
        return f'<PollOption {self.date_time}>'
    
    def get_user_vote(self, user_id):
        """Obtener voto de un usuario para esta opción"""
        return PollVote.query.filter_by(option_id=self.id, user_id=user_id).first()


class PollVote(db.Model):
    __tablename__ = 'poll_votes'
    
    id = db.Column(db.Integer, primary_key=True)
    option_id = db.Column(db.Integer, db.ForeignKey('poll_options.id'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    value = db.Column(db.Integer, nullable=False)  # 5=verde, 3=amarillo, 2=naranja, 0=rojo
    voted_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    user = db.relationship('User', backref='poll_votes')
    
    __table_args__ = (db.UniqueConstraint('option_id', 'user_id', name='_option_user_uc'),)
    
    def __repr__(self):
        return f'<PollVote user={self.user_id} value={self.value}>'
    
    def get_color_name(self):
        """Retornar nombre del color según el valor"""
        colors = {5: 'Verde', 3: 'Amarillo', 2: 'Naranja', 0: 'Rojo'}
        return colors.get(self.value, 'Desconocido')
    
    def get_color_class(self):
        """Retornar clase CSS según el valor"""
        colors = {5: 'success', 3: 'warning', 2: 'orange', 0: 'danger'}
        return colors.get(self.value, 'secondary')
```


---
## config.py
```python
import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    SECRET_KEY = os.getenv('FLASK_SECRET_KEY', 'dev-key-change-in-production')
    # Para psycopg3 usamos postgresql+psycopg en lugar de postgresql
    SQLALCHEMY_DATABASE_URI = os.getenv('DATABASE_URL', 'sqlite:///boardgames.db').replace('postgresql://', 'postgresql+psycopg://')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    ITEMS_PER_PAGE = 12
```

