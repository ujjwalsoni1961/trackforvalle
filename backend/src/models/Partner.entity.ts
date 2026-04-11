import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from "typeorm";
import { Organization } from "./Organisation.entity";

@Entity("partner")
export class Partner {
  @PrimaryGeneratedColumn()
  partner_id: number;

  @Column({ type: "varchar", length: 255, nullable: false })
  company_name: string;

  @Column({ type: "text", nullable: true })
  description: string;

  @Column({ type: "varchar", length: 255, nullable: true })
  contact_email: string;

  @Column({ type: "varchar", length: 50, nullable: true })
  contact_phone: string;

  @Column({ type: "varchar", length: 500, nullable: true })
  logo_url: string;

  @Column({ type: "varchar", length: 500, nullable: true })
  website: string;

  @Column({ type: "int", nullable: true })
  org_id: number;

  @Column({ type: "boolean", default: true })
  is_active: boolean;

  @Column({ type: "char", length: 36, nullable: true })
  created_by: string;

  @Column({ type: "char", length: 36, nullable: true })
  updated_by: string;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @ManyToOne(() => Organization, { onDelete: "SET NULL" })
  @JoinColumn({ name: "org_id" })
  organization: Organization;
}
