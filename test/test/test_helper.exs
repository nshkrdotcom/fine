Application.put_env(:finest, :fine_nif_load_info, %{
  trusted: false,
  max_decode_container_len: 65_536
})

ExUnit.start()
