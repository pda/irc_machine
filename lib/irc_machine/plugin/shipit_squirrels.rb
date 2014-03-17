class IrcMachine::Plugin::ShipItSquirrels < IrcMachine::Plugin::Base
  SQUIRRELS = %w[
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/ship%20it%20squirrel.png
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/squirrel.png
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/Ship%20it1.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/Ship%20it2.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/squirrels.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/SHIP_IT.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/ShipIt1.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/ShipIt2.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/ShipIt3.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/shipitship.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/00IU4s4.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/1L0TbhK.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/33e27I6.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/3426224093_d93a2c75b9_z.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/4145890585_db459aafd6.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/75xBpvk.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/AfTLsO8.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/H8uXLwS.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/HRY8DWi.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/HUBdnqf.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/L1pMLOU.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/O8gcXsl.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/PGAAIa3h.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/WCROsdb.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/fFQBdK4.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/fvCdM7n.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/goDCWg7.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/gvrXV5v.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/inCAP56.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/kcJKwq0.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/mKEZjDS.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/mRxaAK6.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/pECBUWJ.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/qKxZ80K.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/qNVpwT8.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/rDlRbkf.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/u17NYPg.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/uKI2cL3.jpg
    https://s3.amazonaws.com/99designs-shipit-squirrels/shipit.jpg
  ]

  def send_squirrel(channel)
    session.msg channel, SQUIRRELS.sample
  end
end
