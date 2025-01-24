FROM python:3.12

ARG APP_HOME=/app
WORKDIR ${APP_HOME}

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PYTHONPATH=${APP_HOME}

# Install Node.js and Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs npm && \
    npm install -g yarn

# Install Python dependencies
COPY requirements.txt ${APP_HOME}/
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . ${APP_HOME}

# Prepare static files and database
RUN python manage.py collectstatic --noinput
RUN python manage.py migrate

# Build frontend
RUN cd src && yarn install && yarn build

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--config", "gunicorn-cfg.py", "config.wsgi"]
