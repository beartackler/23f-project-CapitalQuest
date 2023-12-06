from flask import Blueprint, jsonify, make_response, request, current_app
from src import db

results_bp = Blueprint('results', __name__)

@results_bp.route('/simulation_results', methods=['GET'])
# getting all simulation results from a database
def get_all_simulation_results():
    cursor = db.get_db().cursor()
    cursor.execute('SELECT * FROM simulation_results')
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    for row in cursor.fetchall():
        json_data.append(dict(zip(row_headers, row)))
    return make_response(jsonify(json_data), 200)

@results_bp.route('/simulation_results/<int:student_id>', methods=['POST'])
def add_results():
    data = request.json
    current_app.logger.info(data)

    simId = data['simId']
    studentId = data['studentId']
    commission = data['commission']
    pnl = data['pnl']
    sr = data['sharpeRatio']
    execScore = data['execScore']

    query = 'INSERT INTO simulation_results(simId, studentId, commission, pnl, sharpeRatio, execScore) VALUES ("'
    query += simId + ', '
    query += studentId + ', '
    query += commission + ', '
    query += pnl + ', '
    query += sr + ', '
    query += execScore + ')'
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    return 'Success!'

@results_bp.route('/simulation_results/<int:student_id>', methods=['GET'])
# getting simulations result for specific student
def get_results_for_student(student_id):
    cursor = db.get_db().cursor()
    cursor.execute('SELECT * FROM simulation_results WHERE student_id = ?', (student_id,))
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    for row in cursor.fetchall():
        json_data.append(dict(zip(row_headers, row)))
    return make_response(jsonify(json_data), 200)

@results_bp.route('/simulation_results/<int:student_id>/<int:simulation_id>', methods=['GET'])
# getting a specific simulation result for a student
def get_specific_result(student_id, simulation_id):
    cursor = db.get_db().cursor()
    cursor.execute('SELECT * FROM simulation_results WHERE student_id = ? AND simulation_id = ?', (student_id, simulation_id))
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    for row in cursor.fetchall():
        json_data.append(dict(zip(row_headers, row)))
    if json_data:
        return make_response(jsonify(json_data), 200)
    else:
        return make_response(jsonify({'error': 'Result not found'}), 404)
