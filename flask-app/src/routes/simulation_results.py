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

@results_bp.route('/simulation_results', methods=['POST'])
# adding results for a simulation by a student
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

@results_bp.route('/simulation_results', methods=['GET'])
# getting the top 10 students with the highest Sharpe ratio in all simulations    
def get_top10_students_sharpe_ratio_all_simulations():
    cursor = db.get_db().cursor()
    cursor.execute('SELECT firstName, lastName FROM simulation_results sr JOIN student s ON sr.studentId = s.student_id ORDER BY sharpeRatio DESC LIMIT 10')
    col_headers = [x[0] for x in cursor.description]
    json_data = []
    for row in cursor.fetchall():
        json_data.append(dict(zip(col_headers, row)))
    return jsonify(json_data)

@results_bp.route('/simulation_results/<simId>', methods=['GET'])
# getting the top 10 students with the highest Sharpe ratio in a specific simulation
def get_top10_students_sharpe_ratio_specific_simulation(simId):
    cursor = db.get_db().cursor()
    cursor.execute('SELECT firstName, lastName FROM simulation_results sr JOIN student s ON sr.studentId = s.student_id WHERE sr.simId = ' + simId + ' ORDER BY sharpeRatio DESC LIMIT 10')
    col_headers = [x[0] for x in cursor.description]
    json_data = []
    for row in cursor.fetchall():
        json_data.append(dict(zip(col_headers, row)))
    return jsonify(json_data)

@results_bp.route('/simulation_results', methods=['GET'])
# getting the top 10 students with the highest pnl in all simulations
def get_top10_students_pnl_all_simulations():
    cursor = db.get_db().cursor()
    cursor.execute('SELECT firstName, lastName FROM simulation_results sr JOIN student s ON sr.studentId = s.student_id ORDER BY pnl DESC LIMIT 10')
    col_headers = [x[0] for x in cursor.description]
    json_data = []
    for row in cursor.fetchall():
        json_data.append(dict(zip(col_headers, row)))
    return jsonify(json_data)

@results_bp.route('/simulation_results/<simId>', methods=['GET'])
# getting the top 10 students with the highest pnl in a specific simulation
def get_top10_students_pnl_specific_simulation(simId):
    cursor = db.get_db().cursor()
    cursor.execute('SELECT firstName, lastName FROM simulation_results sr JOIN student s ON sr.studentId = s.student_id WHERE sr.simId = ' + simId + ' ORDER BY pnl DESC LIMIT 10')
    col_headers = [x[0] for x in cursor.description]
    json_data = []
    for row in cursor.fetchall():
        json_data.append(dict(zip(col_headers, row)))
    return jsonify(json_data)

@results_bp.route('/simulation_results/<simId>', methods=['GET'])
# getting all simulation results from a specific simulation
def get_all_results_from_specific_simulation(simId):
    cursor = db.get_db().cursor()
    cursor.execute('SELECT * FROM simulation_results WHERE simId = ' + simId)
    col_headers = [x[0] for x in cursor.description]
    json_data = []
    for row in cursor.fetchall():
        json_data.append(dict(zip(col_headers, row)))
    return jsonify(json_data)

@results_bp.route('/simulation_results/<studentId>', methods=['GET'])
# getting all simulation results from a specific student
def get_all_results_from_specific_student(studentId):
    cursor = db.get_db().cursor()
    cursor.execute('SELECT * FROM simulation_results WHERE studentId = ' + studentId)
    col_headers = [x[0] for x in cursor.description]
    json_data = []
    for row in cursor.fetchall():
        json_data.append(dict(zip(col_headers, row)))
    return jsonify(json_data)

@results_bp.route('/simulation_results/<simId>', methods=['PUT'])
# delete simulation results for specific simulation
def delete_sim_results_specific_student(simId):
    data = request.json
    current_app.logger.info(data)

    query = f'''DELETE FROM simulation_results WHERE simId = {simId}'''
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    return 'Success!'

@results_bp.route('/simulation_results/<studentId>', methods=['PUT'])
# delete simulation results for specific student
def delete_sim_results_specific_student(studentId):
    data = request.json
    current_app.logger.info(data)

    query = f'''DELETE FROM simulation_results WHERE studentId = {studentId}'''
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    return 'Success!'

@results_bp.route('/simulation_results/<studentId>', methods=['PUT'])
# update simulation results for specific student
def update_sim_results_specific_student(studentId):
    data = request.json
    current_app.logger.info(data)

    simId = data['simId']
    commission = data['commission']
    pnl = data['pnl']
    sharpeRatio = data['sharpeRatio']
    execScore = data['execScore']

    query = f'''UPDATE simulation_results
        SET commission = {commission}, pnl = {pnl}, sharpeRatio = {sharpeRatio}, execScore = {execScore}
        WHERE simId = {simId} AND studentId = {studentId}'''
    
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    return 'Success!'
