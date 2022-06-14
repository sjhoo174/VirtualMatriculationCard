import flask
from flask import request
from flask import render_template
import FaceSimilarity


app = flask.Flask(__name__)
if __name__ == '__main__':
       app.run(debug=True,host='192.168.1.97', port=5000)

# Connections API
@app.route('/compare', methods=['POST'])
def compare():
    try:
        imagefile1 = rrequest.files['imagefile1']
        imagefile2 = request.files['imagefile2']
        embeddings = FaceSimilarity.get_embeddings(imagefile1, imagefile2)
        score = FaceSimilarity.is_match(embeddings[0], embeddings[1])
        thresh= 0.3
        if score <= thresh:
            print('Face is a Match with score of ', score)
            return "YES"
        else:
            print('Face is not a Match with score of ', score)
            return "NO"

    except Exception as err:
        print(err)
        return "NO"


# Similarity API
@app.route('/similarity', methods=['GET'])
def getSimilarity():
    
        
    return render_template('index.html', title=title, output=output)

app.run()


 