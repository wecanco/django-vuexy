FROM python:3.12

ARG APP_HOME=/app
WORKDIR ${APP_HOME}

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install Node.js and Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
   apt-get install -y nodejs && \
   npm install --global yarn

COPY requirements.txt ${APP_HOME}
# install python dependencies
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

COPY . ${APP_HOME}

# running migrations
RUN python manage.py migrate
RUN cd src && yarn install && yarn build

EXPOSE 8000

# gunicorn with port 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--config", "gunicorn-cfg.py", "config.wsgi"]
