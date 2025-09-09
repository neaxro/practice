#!/usr/bin/python3

import os
import requests
import hashlib
import logging

PICTURES_DIR = os.getenv("PICTURES_DIR", "pictures")
PICTURE_COUNT = int(os.getenv("PICTURE_COUNT", "10"))
PICTURE_WIDTH = int(os.getenv("PICTURE_WIDTH", "1600"))
PICTURE_HEIGHT = int(os.getenv("PICTURE_HEIGHT", "900"))
DIRECTORY_LEVEL = int(os.getenv("DIRECTORY_LEVEL", "1"))
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")

logging.basicConfig()
logger = logging.getLogger(__name__)

def get_image(width, height, id = "") -> bytes:
    if id:
        url = f"https://lipsum.app/id/{id}/{width}x{height}"
    else:
        url = f"https://lipsum.app/random/{width}x{height}"

    data = requests.get(url).content
    logger.info(f"Retrieved image with sizes of {width}x{height}.")

    return data

def get_image_abs_dir_path(image_name: str, level = 1, step = 2):
    directories = []
    for i in range(0, level*step, step):
        part = image_name[i:i+step]
        directories.append(part)
    subpath = '/'.join(directories)
    abs_path = f"{PICTURES_DIR}/{subpath}"
    return abs_path

def save_image(content: bytes):
    name = hashlib.sha256(content).hexdigest()
    path = get_image_abs_dir_path(name, DIRECTORY_LEVEL)
    image = f"{path}/{name}.png"

    # Create sub directory is does not exist
    os.makedirs(path, 0o777, exist_ok=True)

    try:
        logger.info(f"Saving {path} ...")
        f = open(image, "wb")
        f.write(content)
    except Exception as e:
        logger.error("Failed to save image:", str(e))
    finally:
        f.close()
        logger.info(f"Saved {image} image!")

def main():
    logger.setLevel(LOG_LEVEL)

    for i in range(1, PICTURE_COUNT+1):
        image = get_image(PICTURE_WIDTH, PICTURE_HEIGHT)
        save_image(image)

        logger.info(f"[{i}/{PICTURE_COUNT}] Progressing...")

    logger.info("Done!")

if __name__ == '__main__':
    main()
