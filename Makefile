COMPOSE_FILE=opensearch.yml

.PHONY: up down restart logs build ps

u:
	docker-compose -f $(COMPOSE_FILE) up -d

d:
	docker-compose -f $(COMPOSE_FILE) down

l:
	docker-compose -f $(COMPOSE_FILE) logs -f

all: d u l

ul: rod u lod

rod:
	docker-compose -f $(COMPOSE_FILE) stop opensearch-dashboards
	docker-compose -f $(COMPOSE_FILE) rm -f opensearch-dashboards

lod:
	docker-compose -f $(COMPOSE_FILE) logs -f opensearch-dashboards
