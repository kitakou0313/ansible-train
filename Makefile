.PHONY: up
up:
	docker compose up -d node-1 node-2

.PHONY: down
down:
	docker compose down -v

.PHONY: ansible
ansible:
	docker compose run --rm -it ansible bash
