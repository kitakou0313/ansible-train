.PHONY: up
up:
	docker compose up -d

.PHONY: down
down:
	docker compose down -v

.PHONY: ansible
ansible:
	docker compose run --rm -it ansible bash