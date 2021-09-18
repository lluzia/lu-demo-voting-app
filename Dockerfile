version: "3.8"

volumes:
    db-data:

networks:
    instavote:
        driver: bridge

services:
    vote:
      image: luzia/vote:latest
      ports:
        - 5000:80
      depends_on:
        - redis
      networks:
        - instavote

    
    redis: 
      image: redis:alpine
      networks: 
        - instavote
    
    db:
      image: postgres:9.4
      volumes:
        - "db-data:/var/lib/postgresql/data"
      networks:
        - instavote
      environment:
        - POSTGRES_HOST_AUTH_METHOD=trust 
    
    result:
      image: luzia/result:latest
      ports:
        - 5001:4000
      depends_on:
        - db
      networks:
        - instavote

    
    worker:
      image: luzia/worker:latest
      depends_on:
        - redis
        - db
      networks:
        - instavote
