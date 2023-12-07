from flask import Blueprint, jsonify, request, current_app
import json
from src import db

simulations = Blueprint('simulations', __name__)

# Get list of all available simulations
@simulations.route('/simulations', methods=['GET'])
def get_simulations():
    cursor = db.get_db().cursor()
    cursor.execute('SELECT simulation_id, name, startDate, endDate FROM simulation')
    column_headers = [x[0] for x in cursor.description]
    json_data = []

    the_data = cursor.fetchall()
    for row in the_data:
        json_data.append(dict(zip(column_headers, row)))

    return jsonify(json_data)

# Create a new simulation #POST
@simulations.route('/simulations', methods=['POST'])
def create_simulation():
    data = request.json
    current_app.logger.info(data)

    name = data['name']
    startDate = data['startDate']
    endDate = data['enddate']


    query = f'INSERT INTO simulation (name, startDate, endDate) VALUES ("{name}", "{startDate}", "{endDate}")'
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    return jsonify({'status': 'Success', 'message': 'Simulation created successfully'})

# View parameters for a specific simulation #GET
@simulations.route('/simulations/<simulation_id>', methods=['GET'])
def view_simulation(simulation_id):
    query = f'SELECT simulation_id, name, startDate, endDate FROM simulation WHERE id = {simulation_id}'
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    column_headers = [x[0] for x in cursor.description]
    json_data = []

    the_data = cursor.fetchall()
    for row in the_data:
        json_data.append(dict(zip(column_headers, row)))

    return jsonify(json_data)

# Update parameters for a specific simulation  #PUT
@simulations.route('/simulations/<int:simulation_id>', methods=['PUT'])
def update_simulation(simulation_id):
    data = request.json
    current_app.logger.info(data)

    if data is None:
        return jsonify({"error": "Invalid request."}), 400

    name = data['name']
    startDate = data['startDate']
    endDate = data['endDate']
    startingBal = data['startingBal']

    query = f'''
        UPDATE simulations
        SET simulation_name = "{name}", startDate = "{startDate}", endDate = "{endDate}", startingBal = "{startingBal}"
        WHERE id = {simulation_id}
    '''
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    return jsonify({'status': 'Success', 'message': 'Simulation updated successfully'})
