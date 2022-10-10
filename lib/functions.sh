
function bootstrap {
    if [ -f "$BASE_DIR/env" ];
    then
        . "$BASE_DIR/env"
    else 
	echo "env file with settings not found"
	exit
    fi

    if [ -f "/etc/os-release" ];
    then
        . /etc/os-release
    fi
}

function createUser {
    local USER_EXISTS=`getent passwd "$USERNAME" | wc -l`
    if [ $USER_EXISTS == "0" ]; 
    then
        echo "Creating $USERNAME"
	echo "Enter the account password..."
        adduser "$USERNAME"
	usermod -aG sudo "$USERNAME"
    else
        echo "$USERNAME exists, not creating"
    fi
}

function addPubKey {
    if [ ! -d "/home/$USERNAME/.ssh" ];
    then
        mkdir "/home/$USERNAME/.ssh";
    fi

    if [ ! -f "/home/$USERNAME/.ssh/authorized_keys" ];
    then
        touch "/home/$USERNAME/.ssh/authorized_keys"
    fi

    local KEY_EXISTS=`cat /home/$USERNAME/.ssh/authorized_keys | grep "$PUBKEY" | wc -l`
    if [ $KEY_EXISTS == "0" ];
    then
        echo "Public key not in authorized keys, adding..."
        echo "$PUBKEY" >> "/home/$USERNAME/.ssh/authorized_keys"
    else
        echo "Public key already in authorized keys"
    fi
    chown -R $USERNAME:$USERNAME "/home/$USERNAME/.ssh"
    chmod 600 "/home/$USERNAME/.ssh/authorized_keys"
}

function sshdConfig { 
        echo "Configuring SSH"
        local PERMIT_ROOT_LOGIN=`cat /etc/ssh/sshd_config | grep "PermitRootLogin no" | wc -l`

	if [ $PERMIT_ROOT_LOGIN == "0" ];
        then
            echo "PermitRootLogin no" >> /etc/ssh/sshd_config
	fi

	local PUB_KEY_AUTH=`cat /etc/ssh/sshd_config | grep '^PubkeyAuthentication yes' | wc -l`
	if [ $PUB_KEY_AUTH == "0" ];
	then
	    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
	fi
	
	local PUB_KEY_TYPES=`cat /etc/ssh/sshd_config | grep "PubkeyAcceptedKeyTypes=+ssh-rsa" | wc -l`
	if [ $PUB_KEY_TYPES == "0" ];
	then
            echo "PubkeyAcceptedKeyTypes=+ssh-rsa" >> /etc/ssh/sshd_config	
        fi
        systemctl restart sshd
}

function github {
    if [ ! -d /home/$USERNAME/.ssh ];
    then
        mkdir /home/$USERNAME/.ssh;
    fi

    if [ ! -f /home/$USERNAME/.ssh/config ];
    then
	touch /home/$USERNAME/.ssh/config
    fi

    local EXISTS=`cat /home/$USERNAME/.ssh/config | grep "Host github.com" | wc -l`
    if [ $EXISTS != "0" ];
    then
        return
    fi

    tee -a /home/$USERNAME/.ssh/config << END
Host github.com
    User git
    Hostname github.com
    PreferredAuthentications publickey
    IdentityFile /home/$USERNAME/.ssh/$USERNAME.key
END

    chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
}
