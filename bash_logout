if [ "$SHLVL" = "1" ] && ! /sbin/save-etc -v -q; then
  echo "Warning! unsaved configuration changes exist in the following files :"
  /sbin/save-etc -v -l | sed -e 's/^/ - /'
  echo "Note: you should use 'config save' after any changes to avoid this warning."
  while : ; do
    read -p "Do you still want to exit without saving (Yes/No/Save) ? "
    rep="${REPLY:0:1}"
    if [ "$rep" = "n" -o "$rep" = "N" ]; then
      exec -l ${SHELL##*/}
    elif [ "$rep" = "s" -o "$rep" = "S" ]; then
      echo -n "Saving changes... "
      /sbin/save-etc -f && echo "done."
      return 0
    elif [ "$rep" = "y" -o "$rep" = "Y" ]; then
      echo "Exiting without saving changes."
      return 0
    else
      echo "=> Please answer Y to exit, N to return to shell or S to save !"
      echo
    fi
  done
fi
