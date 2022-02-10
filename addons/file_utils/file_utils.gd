extends Reference

"""
Collection of commonly used file system related functions.
"""

# Returns the content of a file as a string.
static func as_text(path : String) -> String:
	var file := File.new()
	if file.open(path, File.READ) != OK:
		return ""
	var text := file.get_as_text()
	file.close()
	return text


# Returns the content of a file as a raw binary.
static func as_raw(path : String) -> PoolByteArray:
	var file := File.new()
	if file.open(path, File.READ) != OK:
		return PoolByteArray()
	var raw := file.get_buffer(file.get_len())
	file.close()
	return raw


# Returns the content of a file parsed as json.
static func as_json(path : String) -> Dictionary:
	return parse_json(as_text(path))


# Returns an ImageTexture loaded from a file.
static func as_texture(path : String) -> Texture:
	if not exists(path):
		return null
	if ResourceLoader.has_cached(path) or\
			ProjectSettings.localize_path(path).begins_with("res"):
		return load(path) as Texture
	var image := Image.new()
	if image.load(path) != OK:
		return null
	var texture := ImageTexture.new()
	texture.create_from_image(image)
	texture.resource_path = path
	return texture


# Store the given string in a file. Returns the error if one occured.
static func write(path : String, text : String) -> int:
	var file := File.new()
	var result := file.open(path, File.WRITE)
	if result != OK:
		return result
	file.store_string(text)
	file.close()
	return OK


# Returns true if the given path is either a folder or file.
static func exists(path : String) -> bool:
	var dir := Directory.new()
	return path and dir.dir_exists(path) or dir.file_exists(path)


# Returns a list of non-hidden files inside a given directory.
static func list(path : String) -> Array:
	var dir := Directory.new()
	if dir.open(path) != OK:
		return []
	if dir.list_dir_begin(true, true) != OK:
		return []
	var files := []
	var file := dir.get_next()
	while file:
		files.append(path.plus_file(file))
		file = dir.get_next()
	return files


# Removes the content of a folder recursively.
# Returns the error if any occured.
# WARNING: This function cannot be undone. Be carefull!
static func remove_recursive(path : String) -> int:
	var dir := Directory.new()
	var result := dir.open(path)
	if result != OK:
		return result
	result = dir.list_dir_begin(true, true)
	if result != OK:
		return result
	var file := dir.get_next()
	result = OK
	while file:
		if dir.file_exists(file):
			dir.remove(file)
		elif dir.dir_exists(file):
			var new_result = remove_recursive(path.plus_file(file))
			if new_result != OK:
				result = new_result
		file = dir.get_next()
	return result
