build:
	docker build . -t dropbox
	docker build . -t asdlfkj31h/dropbox:0.3
	docker build . -t t20:5000/dropbox:0.3

push:
	docker push asdlfkj31h/dropbox:0.3
	docker push t20:5000/dropbox:0.3
