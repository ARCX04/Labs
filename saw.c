#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define TIMEOUT 5
#define MAX_SEQ 1
#define TOT_PACKETS 8

#define inc(k) if(k < MAX_SEQ) k++; else k = 0;

typedef struct {
    int data;
} packet;

typedef struct {
    int kind;
    int seq;
    int ack;
    packet info;
    int err;
} frame;

typedef enum { frame_arrival, err, timeout, no_event } event_type;

frame DATA;
int i = 1;
int DISCONNECT = 0;
char turn = 's';  // 's' for sender, 'r' for receiver

void from_network_layer(packet *buffer);
void to_network_layer(packet *buffer);
void to_physical_layer(frame *s);
void from_physical_layer(frame *buffer);
void wait_for_event_sender(event_type *e);
void wait_for_event_receiver(event_type *e);
void sender();
void receiver();

void from_network_layer(packet *buffer) {
    buffer->data = i++;
}

void to_physical_layer(frame *s) {
    s->err = rand() % 4; // probability of error = 1/4
    DATA = *s;
}

void from_physical_layer(frame *buffer) {
    *buffer = DATA;
}

void to_network_layer(packet *buffer) {
    printf("RECEIVER: Packet %d received, ACK sent.\n", buffer->data);
    if (i > TOT_PACKETS) {
        DISCONNECT = 1;
        printf("\nAll packets received. DISCONNECTING...\n");
    }
}

void wait_for_event_sender(event_type *e) {
    static int timer = 0;
    if (turn == 's') {
        timer++;
        if (timer == TIMEOUT) {
            *e = timeout;
            printf("SENDER: ACK not received => TIMEOUT\n");
            timer = 0;
            return;
        }
        if (DATA.err == 0)
            *e = err;
        else {
            timer = 0;
            *e = frame_arrival;
        }
    }
}

void wait_for_event_receiver(event_type *e) {
    if (turn == 'r') {
        if (DATA.err == 0)
            *e = err;
        else
            *e = frame_arrival;
    }
}

void sender() {
    static int frame_to_send = 0;
    static frame s;
    packet buffer;
    event_type event;
    static int flag = 0;

    if (flag == 0) {
        from_network_layer(&buffer);
        s.info = buffer;
        s.seq = frame_to_send;
        printf("SENDER: Sending frame with Info = %d, Seq No = %d\n", s.info.data, s.seq);
        turn = 'r';
        to_physical_layer(&s);
        flag = 1;
    }

    wait_for_event_sender(&event);

    if (turn == 's') {
        if (event == frame_arrival) {
            from_network_layer(&buffer);
            inc(frame_to_send);
            s.info = buffer;
            s.seq = frame_to_send;
            printf("SENDER: Sending frame with Info = %d, Seq No = %d\n", s.info.data, s.seq);
            turn = 'r';
            to_physical_layer(&s);
        }
        if (event == timeout) {
            printf("SENDER: Resending last frame...\n");
            turn = 'r';
            to_physical_layer(&s);
        }
    }
}

void receiver() {
    static int frame_expected = 0;
    frame r, s;
    event_type event;
    wait_for_event_receiver(&event);

    if (turn == 'r') {
        if (event == frame_arrival) {
            from_physical_layer(&r);
            if (r.seq == frame_expected) {
                to_network_layer(&r.info);
                inc(frame_expected);
            } else {
                printf("RECEIVER: Duplicate frame detected, ACK resent.\n");
            }
            turn = 's';
            to_physical_layer(&s);
        }
        if (event == err) {
            printf("RECEIVER: Garbled frame detected.\n");
            turn = 's';
        }
    }
}

int main() {
    srand(time(0)); // Initialize random seed
    printf("=== Stop and Wait ARQ Simulation ===\n\n");

    while (!DISCONNECT) {
        sender();
        receiver();
    }

    printf("\nSimulation complete.\n");
    return 0;
}
