#!/bin/bash

# Check if python3.10 is available
if ! command -v python3.10 &> /dev/null; then
    echo "❌ Error: python3.10 is not installed or not in PATH."
    echo "   Please install Python 3.10 before running this script."
    exit 1
fi

# Check if lsof is available
if ! command -v lsof &> /dev/null; then
    OS=$(uname -s)
    if [ "$OS" = "Linux" ]; then
        # Check for Ubuntu
        if [ -f /etc/os-release ] && grep -qi 'ubuntu' /etc/os-release; then
            echo "🔍 'lsof' not found. Installing lsof (Ubuntu only)..."
            sudo apt update && sudo apt install -y lsof
        else
            echo "❌ Error: 'lsof' is required but not found. Please install it manually."
            exit 1
        fi
    elif [ "$OS" = "Darwin" ]; then
        echo "❌ Error: 'lsof' is required but not found. Please install it manually on macOS."
        exit 1
    else
        echo "❌ Error: 'lsof' is required but not found. Unsupported OS."
        exit 1
    fi
fi

# Check if running as root (not recommended)
if [ "$EUID" -eq 0 ]; then
    echo "⚠️  Warning: Running as root is not recommended"
    echo "   Consider creating a dedicated user for the application"
fi

# open port 8888 for public access (if on Linux and not already open) with (iptables)
if [ "$(uname -s)" = "Linux" ]; then
    if ! sudo iptables -C INPUT -p tcp --dport 8888 -j ACCEPT &> /dev/null; then
        echo "🔓 Opening port 8888 for public access..."
        sudo iptables -A INPUT -p tcp --dport 8888 -j ACCEPT
        echo "✅ Port 8888 opened."
    else
        echo "✅ Port 8888 is already open."
    fi
fi


echo "🚀 Starting JupyterLab server"

# Check if port 8888 is already in use
PID=$(lsof -ti :8888)
if [ ! -z "$PID" ]; then
    echo "❌ Error: Port 8888 is already in use by process ID $PID."
    read -p "Do you want to stop this process? [y/N]: " choice
    case "$choice" in
        y|Y )
            kill -9 $PID
            echo "✅ Process $PID killed."
            ;;
        * )
            echo "⏹️  Please stop the process manually or choose another port."
            exit 1
            ;;
    esac
fi

# Check if virtual environment exists
if [ -d "venv" ]; then
    echo "📦 Activating virtual environment..."
    source venv/bin/activate

    # Install dependencies
    echo "📥 Installing dependencies..."
    pip install -r requirements.txt
else
    echo "⚠️  Virtual environment 'venv' not found."
    read -p "Do you want to create it now? [y/N]: " create_venv
    case "$create_venv" in
        y|Y )
            python3.10 -m venv venv
            echo "✅ Virtual environment 'venv' created."
            source venv/bin/activate
            echo "📥 Installing dependencies..."
            pip install -r requirements.txt
            ;;
        * )
            echo "⏹️  Please create the virtual environment and install dependencies manually."
            exit 1
            ;;
    esac
fi

# Check if JupyterLab config exists, if not generate it
if [ ! -f "$HOME/.jupyter/jupyter_lab_config.py" ]; then
    echo "⚙️  Generating JupyterLab config..."
    jupyter lab --generate-config
    echo "✅ JupyterLab config generated at $HOME/.jupyter/jupyter_lab_config.py"
    
    # Setting JupyterLab working directory to Notebooks folder
    mkdir -p "./Notebooks"
    echo "c.ServerApp.notebook_dir = '$(pwd)/Notebooks'" >> "$HOME/.jupyter/jupyter_lab_config.py"
    echo "✅ JupyterLab working directory set to $(pwd)/Notebooks"
    
    # Set password for JupyterLab
    echo "🔐 Setting JupyterLab password..."
    jupyter lab password
else
    echo "✅ JupyterLab config already exists at $HOME/.jupyter/jupyter_lab_config.py"
fi

# Create logs directory
mkdir -p logs
echo "--------------------[ Starting Server - $(date) ]--------------------" >> logs/access.log
echo "--------------------[ Starting Server - $(date) ]--------------------" >> logs/error.log

# Start the server
echo "🌟 Starting JupyterLab server on http://localhost:8888 and http://${HOSTNAME}:8888"
echo ""

# Run the server in the background and redirect output to logs
nohup jupyter lab --ip=0.0.0.0 --port=8888 --no-browser > logs/access.log 2> logs/error.log &

echo "✅ Server Running in background..."
echo "📊 Access logs: logs/access.log"
echo "🚨 Error logs: logs/error.log"