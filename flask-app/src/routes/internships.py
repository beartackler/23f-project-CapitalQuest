from flask import Blueprint, request, jsonify, make_response
from src import db
import json

internships = Blueprint('internships', __name__)


@internships.route('/internships_available', methods=['GET'])
def list_internships():
    # retrieve all available internships from the database
    cursor = db.get_db().cursor()
    cursor.execute('SELECT * FROM internship')
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    for row in cursor.fetchall():
        json_data.append(dict(zip(row_headers, row)))
    return make_response(jsonify(json_data), 200)


@internships.route('/internships_available/<int:internship_id>', methods=['GET'])
def get_specific_internship(internship_id):
    # retrieve data for a specific internship
    cursor = db.get_db().cursor()
    cursor.execute('SELECT * FROM internship WHERE id = ?', (internship_id,))
    row_headers = [x[0] for x in cursor.description]
    row = cursor.fetchone()
    if row:
        return jsonify(dict(zip(row_headers, row)))
    else:
        return make_response(jsonify({'error': 'Internship not found'}), 404)


@internships.route('/internships_available/company/<string:company_name>', methods=['DELETE'])
def delete_internships_for_company(company_name):
    # delete all internships for a specific company
    cursor = db.get_db().cursor()
    cursor.execute(
        'DELETE FROM internship WHERE company_name = ?', (company_name,))
    db.get_db().commit()
    return jsonify({'message': 'Internships deleted for company {}'.format(company_name)})


@internships.route('/internships_available/<int:internship_id>', methods=['PUT'])
def update_specific_internship(internship_id):
    # update a specific internship
    internship_data = request.json
    cursor = db.get_db().cursor()
    cursor.execute('UPDATE internship SET title = ?, description = ?, other_details = ? WHERE id = ?',
                   (internship_data['title'], internship_data['description'], internship_data.get('other_details', ''), internship_id))
    db.get_db().commit()
    return jsonify({'message': 'Internship updated successfully', 'id': internship_id})


@internships.route('/internships_available', methods=['POST'])
def create_internship():
    # create a new internship
    internship_data = request.json
    cursor = db.get_db().cursor()
    cursor.execute('INSERT INTO internship (title, description, other_details) VALUES (?, ?, ?)',
                   (internship_data['title'], internship_data['description'], internship_data.get('other_details', '')))
    db.get_db().commit()
    return make_response(jsonify({'id': cursor.lastrowid}), 201)
