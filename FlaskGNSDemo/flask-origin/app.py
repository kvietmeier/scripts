######  Flask Application for Image Upload and Annotate Only ######
# This Flask app lists original images and their processed (annotated) versions.
# Users can manually trigger annotation (no resize) of images.
# Processed images are saved separately.
# The app serves original and processed images for viewing in the browser.
#
# Usage:
# 1. Put images into /mnt/vast/gns_demo/images
# 2. Run this script
# 3. Access http://localhost:8080 or http://<server-ip>:8080 in your browser

import os
import random
from flask import Flask, send_file, render_template, redirect, url_for, request, jsonify
from PIL import Image, ImageDraw, ImageFont


app = Flask(__name__)

IMAGE_FOLDER = '/mnt/vast/gns_demo/images'
PROCESSED_FOLDER = '/mnt/vast/gns_demo/processed'

os.makedirs(PROCESSED_FOLDER, exist_ok=True)

def annotate_image(input_path, output_path, reviewer_name="Reviewed by: Karl"):
    image = Image.open(input_path).convert("RGB")
    width, height = image.size
    draw = ImageDraw.Draw(image)

    # --- Font size proportional to image width ---
    proportional_font_size = max(12, width // 40)  # e.g., 20pt for 800px wide image
    try:
        font = ImageFont.truetype("cour.ttf", proportional_font_size)  # 'cour.ttf' is Courier
    except IOError:
        font = ImageFont.load_default()

    # --- Draw reviewer name in top-left corner with 2px buffer ---
    text_position = (2, 2)
    draw.text(text_position, reviewer_name, fill="black", font=font)

    # --- Draw random red rectangle ---
    min_box_size = 50
    max_box_width = width // 3
    max_box_height = height // 3

    box_width = random.randint(min_box_size, max_box_width)
    box_height = random.randint(min_box_size, max_box_height)

    max_x = width - box_width
    max_y = height - box_height

    box_x = random.randint(0, max_x)
    box_y = random.randint(0, max_y)

    box_coords = [(box_x, box_y), (box_x + box_width, box_y + box_height)]
    draw.rectangle(box_coords, outline="red", width=3)

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    image.save(output_path, format='JPEG', quality=95)

    return output_path, box_coords

@app.route('/')
def index():
    images = []
    for filename in os.listdir(IMAGE_FOLDER):
        if filename.lower().endswith(('.png', '.jpg', '.jpeg')):
            processed_name = f"processed_{filename}"
            processed_path = os.path.join(PROCESSED_FOLDER, processed_name)
            images.append({
                "filename": filename,
                "processed_name": processed_name,
                "processed": os.path.exists(processed_path)
            })
    return render_template('index.html', images=images)

@app.route('/images/<filename>')
def image_file(filename):
    return send_file(os.path.join(IMAGE_FOLDER, filename), mimetype='image/jpeg')

@app.route('/processed/<filename>')
def processed_file(filename):
    path = os.path.join(PROCESSED_FOLDER, filename)
    if os.path.exists(path):
        return send_file(path, mimetype='image/jpeg')
    else:
        return f"Processed image {filename} not found.", 404

@app.route('/process/<filename>')
def process_image(filename):
    input_path = os.path.join(IMAGE_FOLDER, filename)
    output_filename = f"processed_{filename}"
    output_path = os.path.join(PROCESSED_FOLDER, output_filename)

    annotate_image(input_path, output_path)

    return redirect(url_for('index'))

@app.route('/api/image_count')
def image_count():
    try:
        files = [f for f in os.listdir(IMAGE_FOLDER) if f.lower().endswith(('.png', '.jpg', '.jpeg'))]
        return jsonify({'count': len(files)})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
