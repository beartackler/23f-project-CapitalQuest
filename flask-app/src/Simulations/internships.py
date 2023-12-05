from flask import Blueprint, request, jsonify, make_response
from src import db

internships_bp = Blueprint('internships', __name__)

@internships_bp.route('/internships_available', methods=['GET'])
def list_internships():
    cursor = db.get_db().cursor()
    cursor.execute('SELECT * FROM internships')
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    for row in cursor.fetchall():
        json_data.append(dict(zip(row_headers, row)))
    return make_response(jsonify(json_data), 200)

@internships_bp.route('/internships_available', methods=['POST'])
def create_internship():
    internship_data = request.json
    cursor = db.get_db().cursor()
    cursor.execute('INSERT INTO internships (title, description, other_details) VALUES (?, ?, ?)',
                   (internship_data['title'], internship_data['description'], internship_data.get('other_details', '')))
    db.get_db().commit()
    return make_response(jsonify({'id': cursor.lastrowid}), 201)
