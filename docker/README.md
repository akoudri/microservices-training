# WordPress Blog with Docker Compose

This Docker Compose configuration sets up a complete WordPress blog application with MariaDB database and phpMyAdmin for database management.

## Services Included

- **WordPress** (wordpress:6.4-apache) - Main blog application
- **MariaDB** (mariadb:10.11) - Database server
- **phpMyAdmin** (phpmyadmin:5.2) - Database management interface

## Quick Start

1. **Clone and navigate to the docker directory:**

   ```bash
   cd /home/ali/Training/micro-services/docker
   ```

2. **Start the services:**

   ```bash
   docker-compose up -d
   ```

3. **Access your WordPress blog:**
   - WordPress: http://localhost:8080
   - phpMyAdmin: http://localhost:8081

## Environment Configuration

For production use, copy `.env.example` to `.env` and modify the values:

```bash
cp .env.example .env
# Edit .env with your preferred values
```

## Default Credentials

### Database

- **Root Password:** `rootpassword123`
- **Database:** `wordpress`
- **Username:** `wordpress`
- **Password:** `wordpress123`

### phpMyAdmin

- **Server:** `db`
- **Username:** `wordpress`
- **Password:** `wordpress123`

## File Structure

```
docker/
├── docker-compose.yaml    # Main Docker Compose configuration
├── uploads.ini           # PHP configuration for file uploads
├── .env.example         # Environment variables template
└── README.md           # This file
```

## Useful Commands

### Start services

```bash
docker-compose up -d
```

### Stop services

```bash
docker-compose down
```

### View logs

```bash
docker-compose logs -f wordpress
docker-compose logs -f db
```

### Restart specific service

```bash
docker-compose restart wordpress
```

### Update services

```bash
docker-compose pull
docker-compose up -d
```

## Data Persistence

The following volumes are created for data persistence:

- `db_data` - MariaDB database files
- `wordpress_data` - WordPress files and uploads

## Performance Features

- **Optimized PHP Settings**: Configured for better file upload handling
- **Health Checks**: All services include health checks for reliability

## Security Considerations

1. **Change default passwords** in production
2. **Use environment variables** for sensitive data
3. **Configure proper firewall rules** for production deployment
4. **Regular backups** of database and WordPress files
5. **Keep images updated** with latest security patches

## Backup and Restore

### Backup Database

```bash
docker exec wordpress_db mysqldump -u wordpress -pwordpress123 wordpress > backup.sql
```

### Restore Database

```bash
docker exec -i wordpress_db mysql -u wordpress -pwordpress123 wordpress < backup.sql
```

## Troubleshooting

### WordPress Installation Issues

If WordPress shows database connection errors:

1. Check if MariaDB is running: `docker-compose ps`
2. Verify database credentials in docker-compose.yaml
3. Check logs: `docker-compose logs db`

### Performance Issues

1. Increase memory limits in uploads.ini
2. Monitor resource usage: `docker stats`

## Production Deployment

For production deployment:

1. Use environment variables for all sensitive data
2. Configure proper domain names
3. Set up SSL/TLS certificates
4. Configure regular backups
5. Implement monitoring and logging
6. Use a reverse proxy (nginx/traefik)

## Support

For issues and questions:

- Check Docker and WordPress documentation
- Review container logs for error messages
- Ensure proper network connectivity between services
