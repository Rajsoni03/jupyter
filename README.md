# JupyterLab Setup

This project provides a convenient script to set up and launch a JupyterLab server on Ubuntu (or compatible Linux systems) with Python 3.10 in a virtual environment.

## Features

- Checks for Python 3.10 and `lsof` (installs `lsof` on Ubuntu if missing)
- Warns if running as root
- Opens port 8888 for public access (Linux only, via `iptables`)
- Checks if port 8888 is in use and offers to kill the process
- Manages a Python virtual environment (`venv`)
- Installs dependencies from `requirements.txt`
- Logs server output to `logs/access.log` and `logs/error.log`
- Starts JupyterLab on `http://localhost:8888` and `http://${HOSTNAME}:8888` in the background

## Quick Start

1. **Clone this repository and enter the directory:**
	```bash
	git clone https://github.com/Rajsoni03/jupyter.git
	cd jupyter
	```

2. **Make the script executable:**
	```bash
	chmod +x start.sh
	```

3. **Run the setup and start the server:**
	```bash
	./start.sh
	```
	- If the virtual environment does not exist, the script will prompt to create it.
	- If port 8888 is in use, you can choose to kill the process or exit.

4. **Access JupyterLab:**
	- Open your browser and go to: [http://localhost:8888](http://localhost:8888) or [http://<HOSTNAME>:8888](http://<HOSTNAME>:8888)

5. **Logs:**
	- Access logs: `logs/access.log`
	- Error logs: `logs/error.log`

## Notes

- The script is designed for Ubuntu but may work on other Linux distributions with minor modifications.
- For non-Ubuntu systems, install `lsof` manually if prompted.
- Do not run the script as root unless necessary.