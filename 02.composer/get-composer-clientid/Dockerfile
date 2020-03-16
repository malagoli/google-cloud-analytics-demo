FROM python
COPY requirements.txt .
RUN pip install -r requirements.txt
ENV GOOGLE_APPLICATION_CREDENTIALS=/serviceaccount.key.json
