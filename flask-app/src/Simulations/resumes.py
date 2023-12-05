from flask import Blueprint, jsonify, request, current_app
from src import db

resumes = Blueprint('resumes', __name__)

# GET /resumes: Retrieve all resumes.
@resumes.route('/resumes', methods=['GET'])
def get_all_resumes():
    cursor = db.get_db().cursor()
    cursor.execute('SELECT student_id, resume_content FROM resumes')
    column_headers = [x[0] for x in cursor.description]
    json_data = []

    the_data = cursor.fetchall()
    for row in the_data:
        json_data.append(dict(zip(column_headers, row)))

    return jsonify(json_data)

# POST /resumes: Add a new resume.
@resumes.route('/resumes', methods=['POST'])
def add_new_resume():
    data = request.json
    current_app.logger.info(data)

    student_id = data['student_id']
    resume_content = data['resume_content']

    query = f'INSERT INTO resumes (student_id, resume_content) VALUES ({student_id}, "{resume_content}")'
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    return jsonify({'status': 'Success', 'message': 'Resume added successfully'})

# GET /resumes/<student_id>: Retrieve resume for a specific student.
@resumes.route('/resumes/<int:student_id>', methods=['GET'])
def get_resume(student_id):
    query = f'SELECT student_id, resume_content FROM resumes WHERE student_id = {student_id}'
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    column_headers = [x[0] for x in cursor.description]
    json_data = []

    the_data = cursor.fetchall()
    for row in the_data:
        json_data.append(dict(zip(column_headers, row)))

    return jsonify(json_data)

# PUT /resumes/<student_id>: Update attached resume for a specific student.
@resumes.route('/resumes/<int:student_id>', methods=['PUT'])
def update_resume(student_id):
    data = request.json
    current_app.logger.info(data)

    resume_content = data['resume_content']

    query = f'UPDATE resumes SET resume_content = "{resume_content}" WHERE student_id = {student_id}'
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    return jsonify({'status': 'Success', 'message': 'Resume updated successfully'})

# DELETE /resumes/<student_id>: Remove attached resume for a specific student.
@resumes.route('/resumes/<int:student_id>', methods=['DELETE'])
def remove_resume(student_id):
    query = f'DELETE FROM resumes WHERE student_id = {student_id}'
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    return jsonify({'status': 'Success', 'message': 'Resume removed successfully'})
