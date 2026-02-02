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
        
        try:
            for option in self.options:
                votes = PollVote.query.filter_by(option_id=option.id).all()
                
                # Contar votos por color
                green = sum(1 for v in votes if v.value == 5)
                yellow = sum(1 for v in votes if v.value == 3)
                orange = sum(1 for v in votes if v.value == 2)
                red = sum(1 for v in votes if v.value == 0)
                
                # Calcular pueden asistir
                can_attend = green + yellow + orange
                total_voters = len(votes)  # Más simple: total de votos
                
                # Calcular promedio de comodidad (solo de los que pueden)
                if can_attend > 0:
                    comfort_avg = sum(v.value for v in votes if v.value > 0) / can_attend
                    comfort_normalized = comfort_avg / 5.0
                else:
                    comfort_avg = 0
                    comfort_normalized = 0
                
                # Calcular ratio de asistencia
                if total_voters > 0:
                    attendance_ratio = can_attend / total_voters
                else:
                    attendance_ratio = 1.0  # Si nadie votó, asume 100%
                
                # NUEVA FÓRMULA: considera cantidad, comfort Y ratio
                if can_attend > 0:
                    final_score = can_attend * (1 + comfort_normalized) * attendance_ratio
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
                    'total_votes': total_voters,
                    'attendance_ratio': attendance_ratio  # NUEVO
                })
        except Exception as e:
            # Log del error para debugging
            print(f"Error en get_results(): {e}")
            import traceback
            traceback.print_exc()
            # Retornar lista vacía en caso de error
            return []
        
        # Ordenar por puntaje final
        results.sort(key=lambda x: x['final_score'], reverse=True)
        return results

    def user_has_voted(self, user_id):
        """Verificar si un usuario ya votó en esta encuesta"""
        if not self.options:
            return False
        
        # Verificar si existe al menos un voto del usuario en alguna opción
        for option in self.options:
            vote = PollVote.query.filter_by(option_id=option.id, user_id=user_id).first()
            if vote:
                return True
        return False

    @staticmethod
    def get_pending_polls_for_user(user_id):
        """Obtener encuestas abiertas donde el usuario NO ha votado"""
        open_polls = Poll.query.filter_by(is_open=True).all()
        pending = []
        
        for poll in open_polls:
            if not poll.user_has_voted(user_id):
                pending.append(poll)
        
        return pending

    @staticmethod
    def get_next_confirmed_event():
        """Obtener la próxima juntada confirmada (encuesta cerrada con fecha futura)"""
        from datetime import datetime
        
        # Buscar encuestas cerradas
        closed_polls = Poll.query.filter_by(is_open=False).all()
        
        now = datetime.now()
        upcoming_events = []
        
        for poll in closed_polls:
            results = poll.get_results()
            if results and results[0]['can_attend'] > 0:
                winner_date = results[0]['option'].date_time
                
                # Solo considerar fechas futuras (incluyendo hoy)
                if winner_date.date() >= now.date():
                    upcoming_events.append({
                        'poll': poll,
                        'date': winner_date,
                        'option': results[0]['option'],
                        'can_attend': results[0]['can_attend'],
                        'voters': results[0]['option'].get_voters_by_color()
                    })
        
        # Ordenar por fecha (más cercana primero)
        upcoming_events.sort(key=lambda x: x['date'])
        
        return upcoming_events[0] if upcoming_events else None


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

    def get_voters_by_color(self):
        """Obtener votantes agrupados por color de voto con sus comentarios"""
        votes = PollVote.query.filter_by(option_id=self.id).all()

        voters = {
            'green': [],   # 5
            'yellow': [],  # 3
            'orange': [],  # 2
            'red': []      # 0
        }

        for vote in votes:
            voter_data = {
                'user': vote.user,
                'comment': vote.comment
            }

            if vote.value == 5:
                voters['green'].append(voter_data)
            elif vote.value == 3:
                voters['yellow'].append(voter_data)
            elif vote.value == 2:
                voters['orange'].append(voter_data)
            elif vote.value == 0:
                voters['red'].append(voter_data)

        return voters

    def get_google_calendar_url(self):
        """Generar URL para agregar evento a Google Calendar"""
        from urllib.parse import quote
        from datetime import timedelta

        # Calcular hora de fin (6 horas después)
        start = self.date_time
        end = start + timedelta(hours=6)

        # Formato: YYYYMMDDTHHmmSS
        date_start = start.strftime('%Y%m%dT%H%M%S')
        date_end = end.strftime('%Y%m%dT%H%M%S')

        # Obtener datos del poll
        poll = self.poll
        title = quote(poll.title or "Juntada de A Jugar!")

        # Obtener confirmados
        voters = self.get_voters_by_color()
        all_attendees = voters['green'] + voters['yellow'] + voters['orange']
        attendees_text = ", ".join([v['user'].username for v in all_attendees])

        # Descripción
        details = quote(
            f"Juntada de A Jugar!\n\n"
            f"Confirmados ({len(all_attendees)}): {attendees_text}\n\n"
            f"Organizador: {poll.creator.username}"
        )

        # Construir URL
        url = (
            f"https://calendar.google.com/calendar/render?action=TEMPLATE"
            f"&text={title}"
            f"&dates={date_start}/{date_end}"
            f"&details={details}"
        )

        # Agregar ubicación si hay descripción
        location = "Julio Sosa 4566, Montevideo, Uruguay"
        url += f"&location={quote(location)}"
        # if self.description:
        #    url += f"&location={quote(self.description)}"

        return url


class PollVote(db.Model):
    __tablename__ = 'poll_votes'
    
    id = db.Column(db.Integer, primary_key=True)
    option_id = db.Column(db.Integer, db.ForeignKey('poll_options.id'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    value = db.Column(db.Integer, nullable=False)  # 5=verde, 3=amarillo, 2=naranja, 0=rojo
    comment = db.Column(db.Text)
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
