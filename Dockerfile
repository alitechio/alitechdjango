FROM python:3.8-alpine
RUN apk add python3-dev build-base linux-headers pcre-dev mariadb-connector-c-dev jpeg-dev zlib-dev freetype-dev lcms2-dev openjpeg-dev tiff-dev tk-dev tcl-dev
RUN apk --update add libxml2-dev libxslt-dev libffi-dev gcc musl-dev libgcc openssl-dev curl
RUN pip install uwsgi

# create the app user
#RUN addgroup -S app && adduser -S app -G app

ENV WORK=/etc/app
ENV WORK_HOME=/etc/app
RUN mkdir $WORK_HOME
WORKDIR $WORK_HOME

COPY ./requirements.txt ./
RUN pip install -r requirements.txt

COPY ./ ./

RUN chown -R nobody:nogroup $WORK_HOME/db.sqlite3

RUN chown -R nobody:nogroup $WORK_HOME

RUN chmod a+rw db.sqlite3 $WORK_HOME/db.sqlite3

CMD ["uwsgi", "--chdir=/etc/app", "--module=alitechdjango.wsgi:application", "--enable-threads" , "--master", "--pidfile=/tmp/project-master.pid", "--http=0.0.0.0:8000", "--processes=5", "--uid=1000", "--gid=2000", "--harakiri=20", "--max-requests=5000", "--vacuum"]

VOLUME /public
VOLUME /uploads
VOLUME /db

# change to the app user
#USER app
