#!/usr/bin/env bash

tigervncserver -localhost no -geometry 1920x1080  -PAMService=login -PlainUsers=lemniscate -SecurityTypes=TLSPlain
