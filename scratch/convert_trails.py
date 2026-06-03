from PIL import Image

def process_red():
	im = Image.open('assets/red-body.png')
	data = list(im.getdata())
	new_data = []
	for p in data:
		if p[3] > 0 and p[0] > 100 and p[1] < 20 and p[2] < 20:
			if p[0] > 220:
				# Bright red -> Neon pink #ff2a7a (255, 42, 122)
				new_data.append((255, 42, 122, p[3]))
			else:
				# Darker red -> Darker neon pink (191, 31, 91)
				new_data.append((191, 31, 91, p[3]))
		else:
			new_data.append(p)
	im.putdata(new_data)
	im.save('assets/red-body.png')
	print("Processed red-body.png successfully.")

def process_blue():
	im = Image.open('assets/blue-body.png')
	data = list(im.getdata())
	new_data = []
	for p in data:
		if p[3] > 0 and p[2] > 100 and p[0] < 20 and p[1] < 20:
			if p[2] > 220:
				# Bright blue -> Neon cyan #00f0ff (0, 240, 255)
				new_data.append((0, 240, 255, p[3]))
			else:
				# Darker blue -> Darker neon cyan (0, 180, 191)
				new_data.append((0, 180, 191, p[3]))
		else:
			new_data.append(p)
	im.putdata(new_data)
	im.save('assets/blue-body.png')
	print("Processed blue-body.png successfully.")

if __name__ == '__main__':
	process_red()
	process_blue()
