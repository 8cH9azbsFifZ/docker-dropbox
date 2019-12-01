build:
	docker build . -t dropbox
	docker build . -t asdlfkj31h/dropbox:0.2

push:
	docker push asdlfkj31h/dropbox:0.2
