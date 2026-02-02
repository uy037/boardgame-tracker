import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    SECRET_KEY = os.getenv('FLASK_SECRET_KEY', 'dev-key-change-in-production')
    # Para psycopg3 usamos postgresql+psycopg en lugar de postgresql
    SQLALCHEMY_DATABASE_URI = os.getenv('DATABASE_URL', 'sqlite:///boardgames.db').replace('postgresql://', 'postgresql+psycopg://')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    ITEMS_PER_PAGE = 12
