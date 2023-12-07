from flask import Blueprint, jsonify, request, current_app
import json
from src import db

resumes = Blueprint('resumes', __name__)

# GET /resumes: getting all student resumes


@resumes.route('/resumes', methods=['GET'])
def get_all_resumespaths():
    cursor = db.get_db().cursor()

    query = '''
        SELECT resumePath
        FROM student
    '''
    cursor.execute(query)

    column_headers = [x[0] for x in cursor.description]
    json_data = []

    the_data = cursor.fetchall()
    for row in the_data:
        json_data.append(dict(zip(column_headers, row)))

    return jsonify(json_data)


# GET /resumes/<student_id>: getting a resume for a specific student
@resumes.route('/resumes/<student_id>', methods=['GET'])
def get_resumepath(student_id):
    query = 'SELECT resumePath FROM student WHERE student_id = ' + \
        str(student_id)
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    column_headers = [x[0] for x in cursor.description]
    json_data = []
    the_data = cursor.fetchall()
    for row in the_data:
        json_data.append(dict(zip(column_headers, row)))
    return jsonify(json_data)

# update specific student resume
@resumes.route('/resumes/<student_id>', methods=['PUT'])
def update_resumepath(student_id):

    the_data = request.get_json()
    current_app.logger.info(the_data)

    if the_data is None:
        return jsonify({"error": "Invalid request. 'resumePath' is required in the request body."}), 400

    cursor = db.get_db().cursor()

    query = 'UPDATE student SET resumePath = %s WHERE student_id = %s'
    cursor.execute(query, (the_data['resumePath'], student_id))
    

    db.get_db().commit()

    return "successfully edited resumepath #{0}!".format(student_id)

# create student resume
@resumes.route('/resumes/<student_id>', methods=['POST'])
def create_resumepath(student_id):

    the_data = request.get_json()
    current_app.logger.info(the_data)

    if the_data is None:
        return jsonify({"error": "Invalid request. 'resumePath' is required in the request body."}), 400

    resumePath = the_data['resumePath']

    insert_query = '''
        INSERT INTO student (id, resumePath) 
        VALUES (%s, %s)
    '''

    cursor = db.get_db().cursor()
    cursor.execute(insert_query, (student_id, resumePath))

    db.get_db().commit()

    return "successfully edited resumepath #{0}!".format(student_id)

# delete student's profil
@resumes.route('/resumes/<student_id>', methods=['DELETE'])
def delete_resumepath(student_id):
    cursor = db.get_db().cursor()
    cursor.execute('DELETE FROM student WHERE student_id = %s', (student_id,))
    db.get_db().commit()
    if cursor.rowcount == 0:
        return jsonify({"message": "resume not found"}), 404
    return jsonify({"message": "Profile deleted successfully"})
    

