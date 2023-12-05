from flask import Blueprint, jsonify, request, current_app
from src import db

stocks = Blueprint('stocks', __name__)

# GET /stocks: Get a list of all stocks
@stocks.route('/stocks', methods=['GET'])
def get_stocks():
    cursor = db.get_db().cursor()
    cursor.execute('SELECT id, stock_name, quantity, price FROM stocks')
    column_headers = [x[0] for x in cursor.description]
    json_data = []

    the_data = cursor.fetchall()
    for row in the_data:
        json_data.append(dict(zip(column_headers, row)))

    return jsonify(json_data)

# POST /stocks: Create a new stock.
@stocks.route('/stocks', methods=['POST'])
def create_stock():
    data = request.json
    current_app.logger.info(data)

    name = data['stock_name']
    quantity = data['quantity']
    price = data['price']

    query = f'INSERT INTO stocks (stock_name, quantity, price) VALUES ("{name}", {quantity}, {price})'
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    return jsonify({'status': 'Success', 'message': 'Stock created successfully'})

# PUT /stocks/<stock_id>: Update values for a specific stock.
@stocks.route('/stocks/<int:stock_id>', methods=['PUT'])
def update_stock(stock_id):
    data = request.json
    current_app.logger.info(data)

    name = data['stock_name']
    quantity = data['quantity']
    price = data['price']

    query = f'''
        UPDATE stocks
        SET stock_name = "{name}", quantity = {quantity}, price = {price}
        WHERE id = {stock_id}
    '''
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    return jsonify({'status': 'Success', 'message': 'Stock updated successfully'})

# DELETE /stocks/<stock_id>: Delete a specific stock.
@stocks.route('/stocks/<int:stock_id>', methods=['DELETE'])
def delete_stock(stock_id):
    query = f'DELETE FROM stocks WHERE id = {stock_id}'
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

    return jsonify({'status': 'Success', 'message': 'Stock deleted successfully'})
