from flask import Flask,request,Response
import json

app = Flask(__name__)

@app.route("/")
def hello():
	n = request.args.get("url")
	#return "succesful " + n
	data = {
        'hello'  : 'world',
        'number' : 3
    }
	js = json.dumps(data)
	resp = Response(js, status=200, mimetype='application/json')
	return resp


@app.route("/feedback")
def collectFeedback():
	n = request.args.get("tirename")
	#return "succesful " + n
	data = {
        'status'  : 'received'
    }
	js = json.dumps(data)
	resp = Response(js, status=200, mimetype='application/json')
	return resp


if __name__ == '__main__':
	app.run(debug=True)