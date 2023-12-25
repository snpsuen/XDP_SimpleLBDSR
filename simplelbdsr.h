#define IP_ADDRESS(x) (unsigned int)(172 + (17 << 8) + (0 << 16) + (x << 24))
#define VIP_ADDRESS(x) (unsigned int)(192 + (168 << 8) + (25 << 16) + (x << 24))

#define LB 2
#define BACKEND_A 3
#define BACKEND_B 4
#define VIP 10

struct serveraddr {
  uint32_t ipaddr;
  uint8_t macaddr[6];
};

struct dispatchmsg_t {
   uint64_t timestamp;
   uint32_t saddr;
   uint32_t backendkey;
};

struct five_tuple {
    uint8_t  protocol;
    uint32_t ip_source;
    uint32_t ip_destination;
    uint16_t port_source;
    uint16_t port_destination;
};

