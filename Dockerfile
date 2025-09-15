# Use official Python slim image
FROM python:3.11-slim
WORKDIR /app

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends sqlite3 \
  && rm -rf /var/lib/apt/lists/*

# Install Python deps first (better caching)
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Now copy the app
COPY . /app

# Expose Flask port
EXPOSE 3000

# Start-up script
CMD bash -c '\
if [ ! -f "quiz.db" ] && [ -f "quiz.sql" ]; then \
  echo "Creating database from quiz.sql..."; \
  sqlite3 quiz.db < quiz.sql; \
fi; \
if [ -f "users.csv" ]; then \
  if [ -f "adduser.py" ]; then \
    echo "Adding users from users.csv..."; \
    python adduser.py; \
  else \
    echo "WARNING: users.csv found but adduser.py missing — skipping."; \
  fi; \
fi; \
echo "Starting Flask server..."; \
python softdes.py \
'
