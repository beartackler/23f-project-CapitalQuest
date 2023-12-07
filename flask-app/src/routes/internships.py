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


@internships.route('/internships_available/<company_id>', methods=['GET'])
def get_specific_internship(company_id):
    # retrieve data for a specific internship
    cursor = db.get_db().cursor()
    cursor.execute('SELECT * FROM internship WHERE company_id = ' + company_id)
    row_headers = [x[0] for x in cursor.description]
    row = cursor.fetchone()
    json_data = []
    for row in cursor.fetchall():
        json_data.append(dict(zip(row_headers, row)))
    return jsonify(json_data)
    


@internships.route('/internships_available/company/<string:company_id>', methods=['DELETE'])
def delete_internships_for_company(company_id):
    # delete all internships for a specific company
    cursor = db.get_db().cursor()
    cursor.execute(
        'DELETE FROM internship WHERE company_id = ?', (company_id,))
    db.get_db().commit()
    return jsonify({'message': 'Internships deleted for company {}'.format(company_id)})


@internships.route('/internships_available/<int:internship_id>', methods=['PUT'])
def update_specific_internship(internship_id):
    # update a specific internship
    internship_data = request.get_json()
    cursor = db.get_db().cursor()
    cursor.execute('UPDATE internship SET name = ?, description = ?, url = ? WHERE id = ?',
                   (internship_data['name'], internship_data['description'], internship_data.get('url', ''), internship_id))
    db.get_db().commit()
    return jsonify({'message': 'Internship updated successfully', 'id': internship_id})


@internships.route('/internships_available', methods=['POST'])
def create_internship():
    internship_data = request.get_json()
    cursor = db.get_db().cursor()
    query = 'INSERT INTO internship (name, description, url, company_id) VALUES (%s, %s, %s, %s)'
    cursor.execute(query, (internship_data['name'], internship_data['description'], internship_data['url'], internship_data['company_id']))
    db.get_db().commit()
    return jsonify({"message": "internship created successfully"}), 201
