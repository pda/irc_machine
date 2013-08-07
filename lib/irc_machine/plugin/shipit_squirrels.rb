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
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/00IU4s4.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/1L0TbhK.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/33e27I6.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/3426224093_d93a2c75b9_z.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/4145890585_db459aafd6.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/75xBpvk.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/AfTLsO8.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/H8uXLwS.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/HRY8DWi.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/HUBdnqf.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/L1pMLOU.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/O8gcXsl.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/PGAAIa3h.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/WCROsdb.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/fFQBdK4.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/fvCdM7n.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/goDCWg7.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/gvrXV5v.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/inCAP56.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/kcJKwq0.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/mKEZjDS.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/mRxaAK6.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/pECBUWJ.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/qKxZ80K.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/qNVpwT8.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/rDlRbkf.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/u17NYPg.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/xzyfer/uKI2cL3.jpg
    https://s3.amazonaws.com/99designs-shipit-squirrels/shipit.jpg
  ]

  def send_squirrel(channel)
    session.msg channel, SQUIRRELS.sample
  end
end
