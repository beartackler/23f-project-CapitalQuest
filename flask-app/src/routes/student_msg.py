from flask import Blueprint, jsonify, make_response, request, current_app
from src import db

messages_bp = Blueprint('messages', __name__)

@messages_bp.route('/student_messages/<int:student_id>', methods=['GET'])
# get all messages for a specific student from the database
def view_messages(student_id):
    cursor = db.get_db().cursor()
    cursor.execute('SELECT * FROM student_messages WHERE student_id = ?', (student_id,))
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    for row in cursor.fetchall():
        json_data.append(dict(zip(row_headers, row)))
    return make_response(jsonify(json_data), 200)

@messages_bp.route('/student_messages/<int:student_id>', methods=['POST'])
# Send a new message to a student
def send_message(student_id):
    data = request.json
    current_app.logger.info(data)

    sender_id = data['sender_id']
    message_content = data['message_content']

    query = f'INSERT INTO student_messages (student_id, sender_id, message_content) VALUES ({student_id}, {sender_id}, "{message_content}")'
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    return jsonify({'status': 'Success', 'message': 'Message sent successfully'})
