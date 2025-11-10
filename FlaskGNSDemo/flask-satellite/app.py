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


def annotate_image(input_path, output_path, reviewer_name="Reviewed by: Maria"):
    image = Image.open(input_path).convert("RGB")
    width, height = image.size
    draw = ImageDraw.Draw(image)

    font_size = max(20, width // 30)  # Proportional + clearly visible

    # Use known-good monospace font on Ubuntu
    font_path = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
    try:
        font = ImageFont.truetype(font_path, font_size)
        print(f"Loaded font from {font_path} with size {font_size}")
    except IOError:
        print("Font not found, using default")
        font = ImageFont.load_default()

    # Test placement: draw white shadow first to improve contrast
    x, y = 10, 10
    shadow_offset = 1
    draw.text((x + shadow_offset, y + shadow_offset), reviewer_name, font=font, fill="black")
    draw.text((x, y), reviewer_name, font=font, fill="white")

    # Red box
    box_width = random.randint(50, width // 3)
    box_height = random.randint(50, height // 3)
    box_x = random.randint(0, width - box_width)
    box_y = random.randint(0, height - box_height)
    draw.rectangle([(box_x, box_y), (box_x + box_width, box_y + box_height)], outline="red", width=3)

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    image.save(output_path, format='JPEG', quality=95)

    print(f"Saved annotated image to {output_path}")
    return output_path, (box_x, box_y, box_x + box_width, box_y + box_height)



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
