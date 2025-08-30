from flask import Flask, request, jsonify
from flask_cors import CORS
import ai_model as rota_modulu

app = Flask(__name__)
CORS(app)

@app.route('/rota-olustur', methods=['POST'])
def rota_olustur():

    data = request.json
    
    if not data or 'enlem' not in data or 'boylam' not in data:
        return jsonify({'error': 'Geçersiz istek. Enlem ve boylam bilgileri gerekli.'}), 400
    
    konum_bilgisi = {
        "enlem": data['enlem'],
        "boylam": data['boylam']
    }
    
    print(f"Alınan konum bilgisi: Enlem={konum_bilgisi['enlem']}, Boylam={konum_bilgisi['boylam']}")
    
    try:

        rotalar = rota_modulu.rota_olustur(konum_bilgisi)
        return jsonify(rotalar)
    except Exception as e:
        print(f"Hata: {str(e)}")
        return jsonify({'error': f'Rota oluşturma hatası: {str(e)}'}), 500

@app.route('/test', methods=['GET'])
def test():
    return jsonify({'status': 'API çalışıyor!'})

if __name__ == '__main__':
    print("API sunucusu başlatılıyor...")
    app.run(host='0.0.0.0', port=5000, debug=True) 