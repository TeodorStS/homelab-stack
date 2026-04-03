.PHONY: up down restart status logs

up:
	@echo "Starting all services..."
	cd nginx && docker compose up -d && cd ..
	cd uptime-kuma && docker compose up -d && cd ..
	cd gitea && docker compose up -d && cd ..
	cd vaultwarden && docker compose up -d && cd ..
	cd pingvin && docker compose up -d && cd ..
	cd portainer && docker compose up -d && cd ..
	cd homer && docker compose up -d && cd ..
	@echo "All services started!"

down:
	@echo "Stopping all services..."
	cd nginx && docker compose down && cd ..
	cd uptime-kuma && docker compose down && cd ..
	cd gitea && docker compose down && cd ..
	cd vaultwarden && docker compose down && cd ..
	cd pingvin && docker compose down && cd ..
	cd portainer && docker compose down && cd ..
	cd homer && docker compose down && cd ..
	@echo "All services stopped!"

status:
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"

logs:
	@docker compose ls

restart: down up
