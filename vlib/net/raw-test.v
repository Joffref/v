import net
import rand

struct Iphdr {	
	ipversion byteptr = 4
	ihl byteptr = 5
	tos byteptr = 0
	tot_len byteptr
	id byteptr
	ttl byteptr = 255
	saddr str
	daddr str
}


fn echo_server(mut c net.RawConn) {
	for {
		mut buf := []byte{len: 100, init: 0}
		read, addr := c.read(mut buf) or { continue }

		c.write_to(addr, buf[..read]) or {
			println('Server: connection dropped')
			return
		}
	}
}

fn echo() ? {

	mut ps_hder := Iphdr{
		tot_len: sizeof(ps_hder) 
		id: rand.int()
		saddr: "127.0.0.1"
		daddr: "127.0.0.1"
	}
	mut c := net.dial_raw('127.0.0.1', net.RawProto.IPPROTO_ICMP) ?
	defer {
		c.close() or { printerr("Pb") }
	}
	data := 'Hello from vlib/net!'

	c.write_str(ps_hder) ?

	mut buf := []byte{len: 100, init: 0}
	read, addr := c.read(mut buf) ?

	assert read == data.len
	println('Got address $addr')


	for i := 0; i < read; i++ {
		assert buf[i] == data[i]
	}

	println('Got "$buf.bytestr()"')

	c.close() ?

	return none
}

fn test_raw() {
	mut l := net.listen_raw(net.RawProto.IPPROTO_ICMP) or {
		println(err)
		assert false
		panic('')
	}

	go echo_server(mut l)
	echo() or {
		println(err)
		assert false
	}

	l.close() or { }
}

fn main() {
	test_raw()
}