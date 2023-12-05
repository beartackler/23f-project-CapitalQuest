from flask import Blueprint, jsonify, request, current_app
from src import db

# GET /simulations: Get a list of all simulations.
# GET /simulations/<simulation_id>: Get details for a specific simulation.
# POST /simulations: Create a new simulation.

simulations = Blueprint('simulations', __name__)

# Get all simulations
@simulations.route('/simulations', methods=['GET'])
def get_simulations():
    cursor = db.get_db().cursor()
    cursor.execute('SELECT id, simulation_name, start_date, end_date FROM simulations')
    column_headers = [x[0] for x in cursor.description]
    json_data = []

    the_data = cursor.fetchall()
    for row in the_data:
        json_data.append(dict(zip(column_headers, row)))

    return jsonify(json_data)

# Get details for a specific simulation
@simulations.route('/simulations/<int:simulation_id>', methods=['GET'])
def get_simulation_detail(simulation_id):
    query = f'SELECT id, simulation_name, start_date, end_date FROM simulations WHERE id = {simulation_id}'
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    column_headers = [x[0] for x in cursor.description]
    json_data = []

    the_data = cursor.fetchall()
    for row in the_data:
        json_data.append(dict(zip(column_headers, row)))

    return jsonify(json_data)

# Create a new simulation
@simulations.route('/simulations', methods=['POST'])
def create_simulation():
    data = request.json
    current_app.logger.info(data)

    name = data['simulation_name']
    start_date = data['start_date']
    end_date = data['end_date']

    query = f'INSERT INTO simulations (simulation_name, start_date, end_date) VALUES ("{name}", "{start_date}", "{end_date}")'
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    return 'Success!'
