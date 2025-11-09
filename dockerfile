# Gunakan image Python 3.11.9 berbasis Ubuntu (bullseye)
FROM python:3.11.9-bullseye

WORKDIR /bobobox

COPY ./requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY ./data ./data
COPY ./images ./images
COPY ./A_Python_Code_Challenge.py .
COPY ./C_Data_Analysis_Challenges.py .

CMD ["sh", "-c", "python3 A_Python_Code_Challenge.py && python3 C_Data_Analysis_Challenges.py"]
