#!/usr/bin/ruby

require 'distem'
private_key = IO.readlines('/root/.ssh/id_rsa').join
public_key = IO.readlines('/root/.ssh/id_rsa.pub').join
sshkeys = {
  'private' => private_key,
  'public' => public_key
}
subnet = '10.158.0.0/22'
Distem.client do |cl|
    c = 0
    cl.vnetwork_create('vnetwork', subnet)
    File.open('/root/nodes') do | fp |
        fp.each_line do | n |
          c+=1
          name = "node#{c}"
	  desc = cl.vnode_create(name,
          {
            'host' => n.chomp,
            'vifaces' => [{'name' => 'if0', 'vnetwork' => 'vnetwork'}],
            #'vmem' => {'hierarchy' => 'v2', 'soft_limit' => 120000, 'swap' => 1024},
	    'vfilesystem' => {'image' => '/home/asaif/public/vnode-env.tgz'}
            #'disk_throttling' => {'hierarchy' => 'v2', 'limits' =>
            #[{'device' => '/dev/sda', 'read_limit' => 100000, 'write_limit' => 100000}]}}
          }, sshkeys)

	  cl.vnode_start(name)
          #puts desc[vifaces][0][address]
         end
    end
end
