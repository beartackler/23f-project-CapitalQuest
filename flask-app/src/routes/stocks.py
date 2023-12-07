from flask import Blueprint, request, jsonify, make_response, current_app
import json
from src import db

stocks = Blueprint('stocks', __name__)


@stocks.route('/stocks', methods=['GET'])
def get_stocks():
    # get a cursor object from the database
    cursor = db.get_db().cursor()

    # use cursor to query the database for a list of products
    cursor.execute('SELECT * FROM stocks')

    # grab the column headers from the returned data
    column_headers = [x[0] for x in cursor.description]

    # create an empty dictionary object to use in
    # putting column headers together with data
    json_data = []

    # fetch all the data from the cursor
    theData = cursor.fetchall()

    # for each of the rows, zip the data elements together with
    # the column headers.
    for row in theData:
        json_data.append(dict(zip(column_headers, row)))

    return jsonify(json_data)


@stocks.route('/stocks/<string:ticker>', methods=['GET'])
def get_stock(ticker):
    cursor = db.get_db().cursor()
    cursor.execute('SELECT * FROM stock WHERE ticker = %s', (ticker,))
    column_headers = [x[0] for x in cursor.description]
    row = cursor.fetchone()
    if row:
        return jsonify(dict(zip(column_headers, row)))
    return jsonify({"message": "Stock not found"}), 404


@stocks.route('/stocks/top5/bid', methods=['GET'])
def get_top5_bid():
    cursor = db.get_db().cursor()
    cursor.execute('SELECT * FROM stock ORDER BY bidPrice DESC LIMIT 5')
    column_headers = [x[0] for x in cursor.description]
    data = cursor.fetchall()
    json_data = [dict(zip(column_headers, row)) for row in data]
    return jsonify(json_data)


@stocks.route('/stocks/top5/ask', methods=['GET'])
def get_top5_ask():
    cursor = db.get_db().cursor()
    cursor.execute('SELECT * FROM stock ORDER BY askPrice DESC LIMIT 5')
    column_headers = [x[0] for x in cursor.description]
    data = cursor.fetchall()
    json_data = [dict(zip(column_headers, row)) for row in data]
    return jsonify(json_data)


@stocks.route('/stocks/top10/eps', methods=['GET'])
def get_top10_eps():
    cursor = db.get_db().cursor()
    cursor.execute('SELECT * FROM stock ORDER BY eps DESC LIMIT 10')
    column_headers = [x[0] for x in cursor.description]
    data = cursor.fetchall()
    json_data = [dict(zip(column_headers, row)) for row in data]
    return jsonify(json_data)


@stocks.route('/stocks', methods=['POST'])
def create_stock():
    data = request.get_json()
    cursor = db.get_db().cursor()
    query = 'INSERT INTO stock (ticker, bidPrice, askPrice, eps, volume, beta) VALUES (%s, %s, %s, %s, %s, %s)'
    cursor.execute(query, (data['ticker'], data['bidPrice'],
                   data['askPrice'], data['eps'], data['volume'], data['beta']))
    db.get_db().commit()
    return jsonify({"message": "Stock created successfully"}), 201


@stocks.route('/stocks/<string:ticker>', methods=['PUT'])
def update_stock(ticker):
    data = request.get_json()
    cursor = db.get_db().cursor()
    query = 'UPDATE stock SET bidPrice = %s, askPrice = %s, eps = %s, volume = %s, beta = %s WHERE ticker = %s'
    cursor.execute(query, (data['bidPrice'], data['askPrice'],
                   data['eps'], data['volume'], data['beta'], ticker))
    db.get_db().commit()
    if cursor.rowcount == 0:
        return jsonify({"message": "Stock not found"}), 404
    return jsonify({"message": "Stock updated successfully"})


@stocks.route('/stocks/<string:ticker>', methods=['DELETE'])
def delete_stock(ticker):
    cursor = db.get_db().cursor()
    cursor.execute('DELETE FROM stock WHERE ticker = %s', (ticker,))
    db.get_db().commit()
    if cursor.rowcount == 0:
        return jsonify({"message": "Stock not found"}), 404
    return jsonify({"message": "Stock deleted successfully"})
