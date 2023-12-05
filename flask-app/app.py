from flask import Flask
from .simulations import simulations
from .stocks import stocks
from .resumes import resumes
from .results import results
from .internships import internships
from .student_msg import student_msg

def create_app():
    app = Flask(__name__)

    # Register Blueprints
    app.register_blueprint(simulations, url_prefix='/simulations')
    app.register_blueprint(stocks, url_prefix='/stocks')
    app.register_blueprint(resumes, url_prefix='/resumes')
    app.register_blueprint(simulation_results, url_prefix='/results')
    app.register_blueprint(internships, url_prefix='/internships')
    app.register_blueprint(student_msg, url_prefix='/communications')

    return app
