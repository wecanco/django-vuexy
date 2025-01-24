FROM python:3.12

# تنظیم متغیرهای مورد نیاز
#ARG APP_HOME=/app
#WORKDIR ${APP_HOME}

# جلوگیری از ایجاد فایل‌های pycache و تنظیم خروجی آنی
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# نصب Node.js و Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install --global yarn

# کپی فایل‌های requirements و نصب وابستگی‌های Python
#COPY requirements.txt ${APP_HOME}/
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# کپی کل پروژه به دایرکتوری داکر
#COPY . ${APP_HOME}
COPY . .

# تنظیم PYTHONPATH برای اطمینان از شناسایی صحیح ماژول‌ها
#ENV PYTHONPATH=${APP_HOME}

# اجرای مهاجرت‌های پایگاه داده
RUN python manage.py collectstatic --noinput
RUN python manage.py migrate

# نصب و بیلد وابستگی‌های فرانت‌اند
RUN cd src && yarn install && yarn build

# باز کردن پورت
EXPOSE 8000

# اجرای سرور Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--config", "gunicorn-cfg.py", "config.wsgi"]
