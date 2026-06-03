from PIL import Image, ImageDraw

def process():
	# Red trail (distinct retro vibrant pure red, full 30x30)
	im_red = Image.new("RGBA", (30, 30), (0, 0, 0, 0))
	draw_red = ImageDraw.Draw(im_red)
	draw_red.rectangle([0, 0, 29, 29], fill=(235, 0, 0, 255), outline=(255, 80, 80, 255), width=2)
	im_red.save("assets/red-body.png")
	
	# Blue trail (distinct retro vibrant pure blue, full 30x30)
	im_blue = Image.new("RGBA", (30, 30), (0, 0, 0, 0))
	draw_blue = ImageDraw.Draw(im_blue)
	draw_blue.rectangle([0, 0, 29, 29], fill=(0, 70, 235, 255), outline=(80, 180, 255, 255), width=2)
	im_blue.save("assets/blue-body.png")
	
	print("Generated sharp retro red and blue trail PNG textures successfully.")

if __name__ == '__main__':
	process()
