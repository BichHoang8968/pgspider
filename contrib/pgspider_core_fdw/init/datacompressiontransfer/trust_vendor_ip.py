from flask import Flask, json

api = Flask(__name__)

@api.route('/', methods=['GET'])
def get_home():
    return '127.0.0.1'

if __name__ == '__main__':
    api.run(host='0.0.0.0', port=2255)
