FROM python:3.11-slim

# Install required Python packages.
RUN pip install requests

# Copy add-on files into the image.
COPY run.sh /run.sh
COPY run.py /run.py
COPY config.yaml /config.yaml

# Make run.sh executable.
RUN chmod +x /run.sh

# Set the default command.
CMD ["/run.sh"]
